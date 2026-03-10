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

## 使い方

### 初回セットアップ（各端末で1回）

```powershell
# 1. このリポジトリをクローン
git clone https://github.com/YOUR_USERNAME/claude-config.git
cd claude-config

# 2. デプロイ（端末名を指定）
.\deploy.ps1 -Machine laptop   # ノートPC
.\deploy.ps1 -Machine office   # 職場PC
.\deploy.ps1 -Machine home     # 自宅PC
```

これで `~/.claude/CLAUDE.md` に共通ルール＋端末固有設定が結合配置され、
`~/.claude/commands/` にカスタムコマンドがコピーされます。

### ルール変更時（どの端末からでもOK）

```powershell
# 1. common.md や端末固有ファイルを編集
# 2. コミット＆プッシュ
git add -A && git commit -m "update rules" && git push

# 3. 他の端末で反映
git pull
.\deploy.ps1 -Machine <この端末名>
```

### multi-agent-shogun のセットアップ

```bash
# WSL2 で実行
git clone https://github.com/yohey-w/multi-agent-shogun.git /mnt/c/tools/multi-agent-shogun
cd /mnt/c/tools/multi-agent-shogun

# 脱戦国パッチ適用
bash /path/to/claude-config/shogun-patches/patch_desengoku.sh

# 詳細は shogun-patches/setup_guide.md を参照
```

## deploy.ps1 の動作

1. `~/.claude/` ディレクトリを作成（なければ）
2. 既存の `CLAUDE.md` をタイムスタンプ付きでバックアップ
3. `common.md` + 指定端末の `.md` を結合して `CLAUDE.md` に配置
4. `commands/` 内の `.md` を `~/.claude/commands/` にコピー

## 端末の追加

新しいPCを追加したい場合：
1. `claude-md/` に新しい `.md` を作成（例: `server.md`）
2. `deploy.ps1` の `ValidateSet` に名前を追加
3. コミット＆プッシュ
