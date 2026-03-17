# Claude Code 修正指示書: 1リポジトリ → 3リポジトリ分割

## 背景

claude-skills として1リポジトリに全部入りで構築したが、設計方針に基づき
3リポジトリ構成に再編する。

参照: self-improving-skills-design.md

---

## 現状（修正前）

```
claude-skills/          ← 全部入り
├── agents/             # 18エージェント（フラット）
├── skills/             # 3スキル
├── logs/
├── proposals/
├── IMPROVEMENT-LOOP.md
├── install.ps1
├── install.sh
├── README.md
└── LICENSE
```

## 目標（修正後）

```
sij-medinfo/
├── claude-config/      ← 既存（変更なし。deploy.ps1の改修は後日）
├── claude-agents/      ← 新規作成
└── claude-skills/      ← 再構成
```

---

## Step 1: claude-agents リポジトリの作成

C:\ClaudeWork\tools\ に claude-agents ディレクトリを新規作成して。

```
claude-agents/
├── README.md
├── LICENSE                    # MIT
├── .gitignore
├── coding/                    # コーディング用エージェントセット
│   ├── architect.md
│   ├── implementer.md
│   ├── tester.md
│   ├── infra.md
│   ├── security.md
│   ├── ops.md
│   └── pm.md
├── stakeholder/               # 病院ステークホルダー用エージェントセット
│   ├── end-user.md
│   ├── comedical.md
│   ├── nurse-manager.md
│   ├── doctor.md
│   ├── medical-clerk.md
│   ├── management.md
│   └── general-affairs.md
├── investigation/             # 調べ物用エージェントセット
│   ├── researcher.md
│   ├── kakarichou.md
│   ├── kakariin.md
│   └── auditor.md
├── logs/                      # Observe: 実行ログ
│   └── .gitkeep
└── proposals/                 # Amend: 改善提案
    └── .gitkeep
```

### エージェントファイルの移動

現在の claude-skills/agents/ から以下のように分類してコピー:

**coding/ （7体）**:
architect.md, implementer.md, tester.md, infra.md, security.md, ops.md, pm.md

**stakeholder/ （7体）**:
end-user.md, comedical.md, nurse-manager.md, doctor.md, medical-clerk.md, management.md, general-affairs.md

**investigation/ （4体）**:
researcher.md, kakarichou.md, kakariin.md, auditor.md

### README.md（claude-agents用）

以下の構成で新規作成:

```markdown
# claude-agents

Claude Code 用マルチエージェント定義。3チーム構成で多角的レビュー・調査を行う。

## チーム構成

### coding（開発チーム: 7体）

| エージェント | 役割 | model |
|:------------|:-----|:------|
| **architect** | システム全体設計のレビュー・提案 | opus |
| **implementer** | コード品質・実装の具体的レビュー | sonnet |
| **tester** | テスト戦略・品質保証の観点 | sonnet |
| **infra** | インフラ・ネットワーク構成の評価 | sonnet |
| **security** | セキュリティ・ガイドライン準拠確認 | sonnet |
| **ops** | 運用・保守性・監視の観点 | sonnet |
| **pm** | スコープ・スケジュール・リスク管理 | sonnet |

### stakeholder（病院ステークホルダーチーム: 7体）

| エージェント | 役割 | model |
|:------------|:-----|:------|
| **end-user** | エンドユーザー目線での操作性評価 | sonnet |
| **comedical** | コメディカル部門の業務要件代弁 | sonnet |
| **nurse-manager** | 看護管理者の視点での業務フロー評価 | sonnet |
| **doctor** | 医師の診療業務視点での評価 | sonnet |
| **medical-clerk** | 医事課の視点での運用・コスト評価 | sonnet |
| **management** | 病院経営層の視点での投資判断 | sonnet |
| **general-affairs** | 総務・庶務視点での規程・調達評価 | sonnet |

### investigation（調査チーム: 4体）

| エージェント | 役割 | model |
|:------------|:-----|:------|
| **researcher** | 技術調査・代替案調査 | opus |
| **kakarichou** | 係長。調査計画の立案（実行しない） | opus |
| **kakariin** | 係員。個別調査タスクの正確な実行 | sonnet |
| **auditor** | 監査員。結果の整合性・抜け漏れチェック + 自己改善ループ運用 | sonnet |

## インストール

deploy.ps1 がこのリポジトリの全エージェントを ~/.claude/agents/ にフラット配置する。
手動の場合:

```bash
# 全サブディレクトリのmdファイルをフラットにコピー
find agents/ -name "*.md" -exec cp {} ~/.claude/agents/ \;
```

## claude-config / claude-skills との関係

```
claude-config（安定系）: CLAUDE.md, hooks/, deploy.ps1
claude-agents（進化系）: エージェント定義。「誰がやるか」
claude-skills（進化系）: スキル定義。「どうやるか」
```

deploy.ps1 が3リポジトリを pull して ~/.claude/ に統合配置する。

## 自己改善ループ

logs/ と proposals/ は自己改善ループ（Observe → Inspect → Amend → Evaluate）用。
詳細は claude-skills/IMPROVEMENT-LOOP.md を参照。

## License

MIT
```

---

## Step 2: claude-skills リポジトリの再構成

現在の claude-skills/ からエージェントを除去し、スキル専用に再構成:

```
claude-skills/
├── README.md                  # ← 書き換え
├── LICENSE
├── .gitignore
├── IMPROVEMENT-LOOP.md        # ← categoryフィールド追加
├── skills/
│   ├── team-dev/
│   │   └── SKILL.md
│   ├── team-stakeholder/
│   │   └── SKILL.md
│   └── team-investigation/
│       └── SKILL.md
├── logs/
│   └── .gitkeep
├── proposals/
│   └── .gitkeep
└── docs/
    └── .gitkeep
```

### 削除対象

- `claude-skills/agents/` ディレクトリごと削除（claude-agentsに移動済み）
- `claude-skills/install.ps1` 削除（deploy.ps1に統合予定）
- `claude-skills/install.sh` 削除（同上）

### README.md の書き換え

```markdown
# claude-skills

Claude Code 用スキル（オーケストレーション手順）定義。

## スキル一覧

| スキル | 役割 | 使用エージェント |
|:------|:-----|:---------------|
| **team-dev** | 開発チーム（7体）による多角的コードレビュー | coding/ の7体 |
| **team-stakeholder** | 病院ステークホルダー（7体）による要件レビュー | stakeholder/ の7体 |
| **team-investigation** | 調査チームの自動オーケストレーション | investigation/ の4体 |

## インストール

deploy.ps1 がこのリポジトリのスキルを ~/.claude/skills/ に配置する。
手動の場合:

```bash
cp -r skills/* ~/.claude/skills/
```

## 自己改善ループ

logs/ と proposals/ は自己改善ループ用。
運用ルールは IMPROVEMENT-LOOP.md を参照。

## claude-config / claude-agents との関係

```
claude-config（安定系）: CLAUDE.md, hooks/, deploy.ps1
claude-agents（進化系）: エージェント定義。「誰がやるか」
claude-skills（進化系）: スキル定義。「どうやるか」
```

## License

MIT
```

### IMPROVEMENT-LOOP.md の修正

JSONLスキーマに category フィールドを追加:

```jsonl
{
  "timestamp": "2026-03-17T10:30:00+09:00",
  "type": "agent",
  "name": "implementer",
  "category": "coding",          ← 追加
  "task_summary": "Pythonスクリプトのコードレビュー",
  ...
}
```

category の値: "coding" | "stakeholder" | "investigation"

---

## Step 3: ~/.claude/ へのインストール

```
1. ~/.claude/agents/ にある既存ファイルをバックアップ
   → ~/backup/claude-agents-backup-YYYYMMDD/ にコピー

2. claude-agents/ の3サブディレクトリ（coding/, stakeholder/, investigation/）
   にある全 .md ファイルを ~/.claude/agents/ にフラットコピー
   （サブディレクトリ構造はデプロイ先では不要）

3. claude-skills/skills/ の3ディレクトリを ~/.claude/skills/ にコピー
   - team-dev/
   - team-stakeholder/
   - team-investigation/

4. ~/.claude/settings.json は触らない

5. claude agents を実行して18エージェントが表示されることを確認
```

---

## Step 4: Git初期化 & GitHub push

### claude-agents

```bash
cd C:\ClaudeWork\tools\claude-agents
git init
git add -A
git commit -m "feat: initial setup - 18 agents in 3 teams (coding/stakeholder/investigation)"
# GitHub sij-medinfo org に claude-agents を private で新規作成
git remote add origin https://github.com/sij-medinfo/claude-agents.git
git branch -M main
git push -u origin main
```

### claude-skills（再構成後）

```bash
cd C:\ClaudeWork\tools\claude-skills
# agents/ 削除、README等書き換え後
git add -A
git commit -m "refactor: remove agents (moved to claude-agents repo), skills-only structure"
git push
```

---

## Step 5: 動作確認

```bash
# エージェント一覧（18体表示されること）
claude agents

# 単体テスト
「implementerサブエージェントでこのプロジェクトの直近のコミットをレビューして」

# 結果を報告して
```

---

## 注意事項

- ~/.claude/settings.json は絶対に上書きしない（hooks定義が入っている）
- 既存の multi-perspective-agents フォルダはバックアップとして残す
- claude-config の deploy.ps1 改修は別タスク（3リポジトリ対応）
- ログにセンシティブ情報を含めないこと
- エージェントのデプロイはフラット化（リポジトリのサブディレクトリ → ~/.claude/agents/ 直下）
