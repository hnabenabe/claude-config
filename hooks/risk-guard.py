#!/usr/bin/env python3
"""
Claude Code PreToolUse Hook: Bash コマンドリスク評価
stdin: {"tool_name": "Bash", "tool_input": {"command": "..."}}
stdout: {"decision": "allow|ask|deny", "reason": "..."}
"""

import json
import re
import sys
import shlex


# ===== 即拒否パターン =====
DENY_PATTERNS = [
    (r'\brm\s+-rf\s+[/~$]', "rm -rf / or ~ は実行禁止"),
    (r'\bmkfs\b', "mkfs は実行禁止"),
    (r'\bdd\s+.*of=/', "dd of=/ は実行禁止"),
    (r'\b:(){ :\|:& };:', "fork bomb は実行禁止"),
    (r'\breg\s+delete\s+.*HKLM', "レジストリ HKLM 削除は実行禁止"),
    (r'\bFormat-Volume\b', "Format-Volume は実行禁止"),
    (r'\bClear-Disk\b', "Clear-Disk は実行禁止"),
]

# ===== シークレット検出パターン =====
SECRET_PATTERNS = [
    (r'\bsk-[a-zA-Z0-9]{20,}', "API key (sk-) がコマンドに含まれている"),
    (r'\bghp_[a-zA-Z0-9]{36,}', "GitHub PAT がコマンドに含まれている"),
    (r'\bAKIA[A-Z0-9]{16}', "AWS Access Key がコマンドに含まれている"),
    (r'\bxoxb-[a-zA-Z0-9-]+', "Slack Bot Token がコマンドに含まれている"),
    (r'\bglpat-[a-zA-Z0-9-]{20,}', "GitLab PAT がコマンドに含まれている"),
]

# ===== 読み取り専用コマンド（自動承認） =====
READONLY_COMMANDS = {
    "cat", "less", "more", "head", "tail", "wc", "file", "stat",
    "ls", "dir", "tree", "find", "locate", "which", "where", "type",
    "grep", "rg", "ag", "ack", "findstr", "Select-String",
    "echo", "printf", "Write-Output", "Write-Host",
    "pwd", "cd", "pushd", "popd",
    "date", "cal", "whoami", "hostname", "uname", "env", "printenv",
    "git log", "git status", "git diff", "git branch", "git show",
    "git remote", "git tag", "git stash list",
    "python --version", "python3 --version", "pip --version",
    "pip list", "pip show", "pip freeze",
    "node --version", "npm --version", "npm list", "npm ls",
    "code --version", "claude --version",
    "Get-Content", "Get-ChildItem", "Get-Item", "Get-Location",
    "Test-Path", "Measure-Object",
}

# ===== 高リスク操作（要確認） =====
HIGH_RISK_PATTERNS = [
    (r'\brm\b', "ファイル削除"),
    (r'\bmv\b', "ファイル移動"),
    (r'\bMove-Item\b', "ファイル移動"),
    (r'\bRemove-Item\b', "ファイル削除"),
    (r'\bpip\s+install\b', "パッケージインストール"),
    (r'\bnpm\s+install\b', "パッケージインストール"),
    (r'\bgit\s+push\b', "リモートへプッシュ"),
    (r'\bgit\s+reset\s+--hard\b', "git 強制リセット"),
    (r'\bgit\s+clean\b', "git clean"),
    (r'\bcurl\b.*\b-X\s*(POST|PUT|DELETE)\b', "HTTP書き込みリクエスト"),
    (r'\bcurl\b.*\b--data\b', "HTTP POSTデータ送信"),
    (r'\bInvoke-WebRequest\b.*-Method\s*(Post|Put|Delete)', "HTTP書き込みリクエスト"),
    (r'>\s*[^&]', "ファイルへのリダイレクト書き込み"),
    (r'>>', "ファイルへの追記"),
    (r'\bchmod\b', "パーミッション変更"),
    (r'\bchown\b', "オーナー変更"),
    (r'\bsudo\b', "管理者権限実行"),
    (r'\bSet-ExecutionPolicy\b', "実行ポリシー変更"),
]

# ===== 検索エンジン（自動承認） =====
SEARCH_ENGINE_DOMAINS = [
    "google.com/search", "bing.com/search", "yahoo.co.jp/search",
    "duckduckgo.com", "search.yahoo.com",
]


def extract_base_command(segment: str) -> str:
    """パイプ区切りのセグメントから先頭コマンドを抽出"""
    segment = segment.strip()
    # 環境変数プレフィックスをスキップ
    while re.match(r'^[A-Z_]+=\S+\s', segment):
        segment = re.sub(r'^[A-Z_]+=\S+\s+', '', segment)
    parts = segment.split()
    return parts[0] if parts else ""


def split_pipeline(command: str) -> list:
    """パイプラインを分割（クォート内のパイプは無視）"""
    segments = []
    current = []
    in_single = False
    in_double = False
    i = 0
    while i < len(command):
        c = command[i]
        if c == "'" and not in_double:
            in_single = not in_single
        elif c == '"' and not in_single:
            in_double = not in_double
        elif c == '|' and not in_single and not in_double:
            if i + 1 < len(command) and command[i + 1] == '|':
                # || は論理OR、パイプではない
                current.append('||')
                i += 2
                continue
            segments.append(''.join(current))
            current = []
            i += 1
            continue
        current.append(c)
        i += 1
    if current:
        segments.append(''.join(current))
    return segments


def classify_command(command: str) -> tuple:
    """
    コマンドのリスクレベルを判定。
    Returns: (decision, reason) — decision: "allow" | "ask" | "deny"
    """
    # 1. 即拒否チェック
    for pattern, reason in DENY_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            return ("deny", reason)

    # 2. シークレット検出
    for pattern, reason in SECRET_PATTERNS:
        if re.search(pattern, command):
            return ("deny", reason)

    # 3. 検索エンジンへのアクセスは許可
    if re.search(r'\bcurl\b', command, re.IGNORECASE):
        for domain in SEARCH_ENGINE_DOMAINS:
            if domain in command:
                return ("allow", f"検索エンジンアクセス: {domain}")

    # 4. パイプライン分割して全段チェック
    segments = split_pipeline(command)
    base_commands = [extract_base_command(seg) for seg in segments]

    # 全段が読み取り専用か
    all_readonly = True
    for seg in segments:
        seg_stripped = seg.strip()
        is_readonly = False
        for ro_cmd in READONLY_COMMANDS:
            if seg_stripped.startswith(ro_cmd):
                is_readonly = True
                break
        if not is_readonly:
            all_readonly = False
            break

    if all_readonly:
        return ("allow", "全段が読み取り専用コマンド")

    # 5. 高リスク操作の検出
    for pattern, reason in HIGH_RISK_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            return ("ask", f"要確認: {reason}")

    # 6. 未分類 → 安全側に倒す
    return ("ask", "未分類のコマンド — 確認が必要")


def main():
    try:
        input_data = json.loads(sys.stdin.read())
    except (json.JSONDecodeError, EOFError):
        # パース失敗時は何もしない（他のhookに委ねる）
        sys.exit(0)

    tool_name = input_data.get("tool_name", "")
    if tool_name != "Bash":
        # Bash以外のツールはこのhookの対象外
        sys.exit(0)

    command = input_data.get("tool_input", {}).get("command", "")
    if not command:
        sys.exit(0)

    decision, reason = classify_command(command)

    result = {"decision": decision}
    if reason:
        result["reason"] = reason

    print(json.dumps(result))


if __name__ == "__main__":
    main()
