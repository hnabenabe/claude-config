# claude-config

Claude Code のグローバルルール・カスタムコマンド・shogunパッチを一元管理するリポジトリ。

## 導入するとどうなるか

`deploy.ps1` を実行すると、Claude Code に以下のルールと制限が自動適用されます。

### 全端末共通ルール（common.md）

**言語**
- すべての応答が日本語になる

**ファイル保護**
- 既存ファイルの上書き前に必ず確認が入る
- 変更前にバックアップ（`.bak`）が作成される
- `rm -rf` はいかなる場合も実行されない
- `rm`、`del`、`rmdir` は対象一覧を表示して承認を得てから実行される

**パッケージインストール制限**
- `npm install`、`pip install`、`brew install` 等の実行前に、パッケージ名・目的・影響範囲（グローバル/ローカル）の説明が入る
- 承認するまで実行されない

**コマンド実行前の説明義務**
- 技術的なコマンドは実行前に日本語で「何をするか」「結果と影響」「リスク」が説明される
- 「実行してよいですか？」と確認が入る
- 不明な点があれば実行前に確認される

### 端末固有の設定

| 端末 | 主な設定内容 |
|------|------------|
| laptop | WinPython のフルパス指定、WSL2利用可 |
| office | 院内ネットワーク考慮、外部API接続前にプロキシ確認必須、院内データの外部送信禁止 |
| home | Tailscale経由のリモートアクセス、WSL2利用可 |

### カスタムコマンド

**`/handover`** — セッション終了時に引き継ぎ書（HANDOVER.md）を自動生成する。以下を含む：
- 完了した作業
- 重要な意思決定とその理由
- 発生した問題と解決方法
- 学んだ教訓・ハマりポイント
- 次にやるべきステップ
- 重要ファイル一覧

## 構成

```
claude-config/
├── CLAUDE.md                # Claude Code 自動読み込み用
├── claude-md/
│   ├── common.md            # 全端末共通ルール（安全・日本語）
│   ├── laptop.md            # 高性能ノートPC（WinPython）
│   ├── office.md            # 職場デスクトップ
│   └── home.md              # 自宅PC（SSH検証用）
├── commands/
│   └── handover.md          # /handover コマンド
├── shogun-patches/
│   ├── patch_desengoku.sh   # 脱戦国パッチ
│   ├── setup_guide.md       # 導入ガイド
│   └── setup_guide_wsl2.md  # WSL2セットアップ
├── deploy.ps1               # デプロイスクリプト
└── README.md
```

## セットアップ手順

### 1. GitHub認証の準備（初回のみ）

GitHubはパスワード認証に対応していないため、以下のいずれかで認証してください。

**方法A: GitHub CLI（おすすめ）**

```powershell
# GitHub CLI をインストール（winget）
winget install GitHub.cli

# ログイン（ブラウザで認証）
gh auth login
```

これで以降の git clone / push / pull がすべて自動認証されます。

**方法B: Personal Access Token (PAT)**

1. https://github.com/settings/tokens にアクセス
2. 「Generate new token (classic)」→ `repo` にチェック → 生成
3. 表示されたトークン（`ghp_...`）をコピーしておく

### 2. リポジトリをクローン

```powershell
# GitHub CLI で認証済みの場合
git clone https://github.com/hnabenabe/claude-config.git C:\ClaudeWork\tools\claude-config

# PAT を使う場合（パスワード欄にトークンを貼り付け）
git clone https://hnabenabe@github.com/hnabenabe/claude-config.git C:\ClaudeWork\tools\claude-config
```

### 3. Claude Code でセットアップ

クローンしたディレクトリで Claude Code を起動し、以下のように指示してください。

```powershell
cd C:\ClaudeWork\tools\claude-config
claude
```

Claude Code に対して：

> この端末の環境に合わせて deploy.ps1 を実行して、CLAUDE.md をセットアップして。

Claude Code が自動的に以下を行います：
- 端末の環境（OS、Pythonパス等）を判別
- 適切な端末名（laptop / office / home）で `deploy.ps1` を実行
- `~/.claude/CLAUDE.md` に共通ルール＋端末固有設定を結合配置
- `~/.claude/commands/` にカスタムコマンドをコピー

### 端末と設定の対応

| 端末名 | 対象 | 特徴 |
|--------|------|------|
| `laptop` | 高性能ノートPC | WinPython環境、WSL2あり |
| `office` | 職場デスクトップ | 院内ネットワーク、プロキシ考慮 |
| `home` | 自宅PC | Tailscale、SSH検証用 |

## ルール変更時

どの端末からでも Claude Code に指示するだけでOKです。

> common.md の○○ルールを修正して、コミット＆プッシュして。

他の端末で反映するときも同様に：

> git pull して、この端末に合わせて再デプロイして。

## 端末の追加

新しいPCを追加したい場合も Claude Code に任せられます。

> 新しい端末「server」用の設定ファイルを追加して。環境は Ubuntu 24.04、Python は pyenv 管理。

Claude Code が以下を行います：
1. `claude-md/server.md` を作成
2. `deploy.ps1` の `ValidateSet` に `server` を追加
3. コミット＆プッシュ

## deploy.ps1 の動作

1. `~/.claude/` ディレクトリを作成（なければ）
2. 既存の `CLAUDE.md` をタイムスタンプ付きでバックアップ
3. `common.md` + 指定端末の `.md` を結合して `CLAUDE.md` に配置
4. `commands/` 内の `.md` を `~/.claude/commands/` にコピー

## multi-agent-shogun のセットアップ

Claude Code に以下のように指示してください。

> WSL2 で multi-agent-shogun をセットアップして。詳細は shogun-patches/setup_guide.md を参照して。
