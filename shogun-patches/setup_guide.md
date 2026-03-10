# multi-agent-shogun 導入ガイド（Windows WSL2 / 脱・戦国 / 2体構成）

## 概要

multi-agent-shogunの階層型マルチエージェント構造を、Windows WSL2上で、
ビジネス日本語・ワーカー2体のミニマム構成で運用するためのガイドです。

## 前提

- Windows 10 (22H2以降) または Windows 11
- Claude Team plan プレミアムシート（Claude Code利用可能）
- Windows Terminal（推奨、Microsoft Storeから入手可能）

## 手順

---

### Step 1: WSL2 + Ubuntu のセットアップ

リポジトリに `install.bat` が付属しています。

**PowerShell（管理者）で実行：**

```powershell
# WSL2が未インストールの場合
wsl --install
# → 再起動が必要になる場合あり

# 再起動後、Ubuntuが未設定なら
wsl --install -d Ubuntu
```

もしくはリポジトリの `install.bat` を管理者として実行すれば、
WSL2とUbuntuの有無を自動チェックしてセットアップしてくれます。

Ubuntuを初めて起動するとユーザー名・パスワードの設定を求められるので設定してください。

---

### Step 2: リポジトリ配置

Windows側のフォルダにcloneし、WSLからアクセスします。

**Windows側（PowerShellまたはエクスプローラー）：**

```powershell
# C:\tools に配置する例（GitHubでfork済みの場合）
cd C:\tools
git clone https://github.com/<your-user>/multi-agent-shogun.git
```

**WSL側からのアクセスパス：**

```bash
cd /mnt/c/tools/multi-agent-shogun
```

> **注意**: リポジトリ本体は `/mnt/c/` 以下（Windows FS）で問題ありませんが、
> inboxキュー（inotifywait使用）は自動的にLinux FS側（`~/.local/share/multi-agent-shogun/inbox`）に
> シンボリックリンクされます。これは出陣スクリプトが自動で処理するので手動操作は不要です。

---

### Step 3: 脱・戦国パッチ適用

`patch_desengoku.sh` をリポジトリのルートに配置して実行します。

```bash
# WSL (Ubuntu) で実行
cd /mnt/c/tools/multi-agent-shogun

# パッチファイルをコピー（ダウンロードした場所に応じて調整）
cp /mnt/c/Users/<your-user>/Downloads/patch_desengoku.sh .

# 実行
bash patch_desengoku.sh

# 確認（0件になればOK）
grep -rn '戦国\|ござる\|sengoku\|つかまつ\|battle cry' instructions/ CLAUDE.md | wc -l
```

---

### Step 4: first_setup.sh を実行

```bash
cd /mnt/c/tools/multi-agent-shogun
./first_setup.sh
```

これにより以下が自動セットアップされます：

- tmux, jq, inotify-tools 等のパッケージ
- Node.js（未インストールの場合はnvm経由）
- Claude Code（`npm install -g @anthropic-ai/claude-code`）
- Python venv + 依存パッケージ
- `config/settings.yaml` の生成
- キューファイルの初期化

途中でシェル選択（bash/zsh）を聞かれるので選択してください。

---

### Step 5: settings.yaml を編集（2体構成）

`config/settings.yaml` を編集して、足軽を2体に絞ります。

```bash
# VSCode（Windows側）で編集する場合
code config/settings.yaml
# または WSL内で
nano config/settings.yaml
```

以下の内容に書き換え（または追記）してください：

```yaml
# multi-agent-shogun 設定ファイル

language: ja
shell: bash

# CLI + モデル設定（2体構成）
cli:
  default: claude
  agents:
    shogun:
      type: claude
      model: claude-sonnet-4-5-20250929
    karo:
      type: claude
      model: claude-sonnet-4-5-20250929
    ashigaru1:
      type: claude
      model: claude-sonnet-4-5-20250929
    ashigaru2:
      type: claude
      model: claude-sonnet-4-5-20250929
    gunshi:
      type: claude
      model: claude-sonnet-4-5-20250929

# bloom_routing を off にして動的モデル切替を無効化（シンプル運用向け）
bloom_routing: "off"

# スキル設定
skill:
  save_path: "~/.claude/skills/"
  local_path: "./skills/"

# ログ設定
logging:
  level: info
  path: "./logs/"
```

**Team Premium枠でのモデル選択ポイント：**

- 全エージェントSonnetで統一するのが最も枠に優しい
- shogunだけOpus（`claude-opus-4-6`）にすると判断品質が上がるが、枠の消費も増える
- まずは全Sonnetで試して、足りなければshogunだけOpusに切り替える運用がおすすめ

---

### Step 6: 出陣（起動）

```bash
cd /mnt/c/tools/multi-agent-shogun

# クリーンスタート（キューリセット）
./shutsujin_departure.sh -c

# サイレントモード（echo表示省略でAPI節約）を併用する場合
./shutsujin_departure.sh -c -S
```

Windows Terminalを使っている場合は `-t` オプションで自動タブ分割もできます：

```bash
./shutsujin_departure.sh -c -t
```

---

### Step 7: 使う

tmuxのshogunウィンドウで指示を出すだけです。

```
このプロジェクトのREADMEを整備して
テストを書いて実行して
```

**tmux操作の基本：**

| 操作 | キー |
|------|------|
| ウィンドウ切替 | `Ctrl+B` → `0`/`1`/`2` |
| デタッチ（バックグラウンドに） | `Ctrl+B` → `d` |
| 再アタッチ | `tmux attach -t shogun` |
| ペイン間移動 | `Ctrl+B` → 矢印キー |

**ダッシュボード確認：**

`dashboard.md` がリアルタイムで更新されるので、VSCodeのMarkdownプレビューで開いておくと進捗が見えます。

```powershell
# Windows側で
code C:\tools\multi-agent-shogun\dashboard.md
```

---

## 構成図（2体構成）

```
    人間（Windows側で指示・ダッシュボード確認）
     |
   +--- WSL2 (Ubuntu) --- tmux ---------------+
   |                                           |
   |  shogun  -> karo  ->  ashigaru1           |
   |                   ->  ashigaru2           |
   |                   <-  gunshi（品質チェック）|
   |                                           |
   +-------------------------------------------+
```

---

## 日常運用

### 毎日の起動

```bash
wsl
cd /mnt/c/tools/multi-agent-shogun
./shutsujin_departure.sh
```

### 停止

```bash
# tmux内で
tmux kill-session -t shogun
tmux kill-session -t multiagent
```

### トラブルシューティング

| 症状 | 対処 |
|------|------|
| Claude Codeが `claude` コマンドで起動しない | `npm install -g @anthropic-ai/claude-code` を再実行 |
| inotifywaitが動かない | `/mnt/c/` 上ではinotifyが効かないのが正常。inboxのシンボリックリンクを確認：`ls -la queue/inbox` |
| 足軽がタスクを拾わない | karoウィンドウで状態確認。`cat queue/tasks/ashigaru1.yaml` でstatus確認 |
| 枠を使い切った | `-S`（サイレント）で再起動。不要なエージェントを減らす |
| tmuxセッションが残っている | `tmux ls` で確認、`tmux kill-server` で全セッション終了 |

---

## パッチが変更するもの / しないもの

**変更するもの：**
- `speech_style: "戦国風"` → `"ビジネス"`
- 例文の口調（「はっ！」「承知つかまつった」→「了解しました」「承知しました」）
- echo_message / battle cry → status message
- instructions/ 以下の全ロールファイル + CLAUDE.md

**変更しないもの：**
- ロール名（shogun, karo, ashigaru, gunshi）
- スクリプト類（shutsujin_departure.sh, inbox_write.sh 等）
- YAML通信プロトコル・イベント駆動の仕組み
- tmux構成ロジック
- shutsujin_departure.sh のバナー・ヘルプテキスト（動作に影響なし）
