# claude-config

Claude Code のグローバルルール・カスタムコマンド・shogunパッチを一元管理するリポジトリ。

## 構成

```
claude-config/
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

### 1. リポジトリをクローン

```powershell
git clone https://github.com/hnabenabe/claude-config.git C:\ClaudeWork\tools\claude-config
```

### 2. Claude Code でセットアップ

クローンしたディレクトリで Claude Code を起動し、以下のように指示してください。

```
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
