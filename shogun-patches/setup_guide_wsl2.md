# multi-agent-shogun 導入ガイド（脱・戦国 + 2体構成）

## 概要

multi-agent-shogunの階層型マルチエージェント構造を、戦国口調なしの普通のビジネス日本語で、
ワーカー2体のミニマム構成で運用するためのガイドです。

## 前提

- Claude Team plan プレミアムシート（Claude Code利用可能）
- WSL2 または Linux/macOS環境
- Node.js（Claude Codeのインストールに必要）

## 手順

### 1. リポジトリをfork & clone

```bash
# GitHubでfork後
git clone https://github.com/<your-user>/multi-agent-shogun.git
cd multi-agent-shogun
```

### 2. 脱・戦国パッチ適用

```bash
# patch_desengoku.sh をプロジェクトルートに配置して実行
bash patch_desengoku.sh

# 確認（0件になればOK）
grep -rn '戦国\|ござる\|sengoku\|つかまつ\|battle cry' instructions/ CLAUDE.md | wc -l
```

### 3. first_setup.sh を実行

```bash
./first_setup.sh
```

これで `config/settings.yaml` が生成されます。

### 4. settings.yaml を編集（2体構成 + 口調設定）

`config/settings.yaml` を以下のように編集します：

```yaml
# multi-agent-shogun 設定ファイル

language: ja

shell: bash

# CLI設定（2体構成）
cli:
  default: claude
  agents:
    shogun:
      type: claude
      model: claude-opus-4-6
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

# スキル設定
skill:
  save_path: "~/.claude/skills/"
  local_path: "./skills/"

# ログ設定
logging:
  level: info
  path: "./logs/"
```

**ポイント:**
- ashigaru1とashigaru2だけ定義 → 自動的に2体構成になる
- Team Premium枠を考慮してSonnet中心にする
- gunshiは品質チェック担当なので残す（不要なら省略可）

### 5. 出陣

```bash
./shutsujin_departure.sh -c   # クリーンスタート
```

### 6. 使い方

shogunウィンドウで指示を出すだけです：

```
「このプロジェクトのREADMEを整備して」
「テストを書いて実行して」
```

## 構成図（2体構成）

```
    人間
     ↓ 指示
   shogun (Claude Code - Opus)
     ↓ タスク分解を指示
    karo (Claude Code - Sonnet)
     ↓ 個別タスクYAML作成
  ┌──────┐──────┐
  │ W1   │ W2   │  ← ashigaru1, ashigaru2 (Sonnet)
  └──────┘──────┘
     ↓ 報告
   gunshi (品質チェック)
     ↓ ダッシュボード更新
   karo → shogun → 人間
```

## パッチが変更するもの

| 対象 | 変更内容 |
|------|----------|
| `speech_style` | `"戦国風"` → `"ビジネス"` |
| 言語設定 | 「はっ！」「承知つかまつった」 → 「了解しました」「承知しました」 |
| echo_message例 | 「足軽1号、先陣を切って参る！」 → 「ワーカー1、タスク開始します」 |
| 報告メッセージ | 「任務完了でござる」 → 「タスク完了」 |
| battle cry | → status message |

**変更しないもの:**
- ロール名（shogun, karo, ashigaru, gunshi）→ スクリプトに深く組み込まれているため
- YAML通信プロトコル
- inbox/イベント駆動の仕組み
- tmux構成ロジック
- shutsujin_departure.sh のバナー表示（動作に影響なし）

## Team Premium枠での運用Tips

- サイレントモードで起動すると echo 表示を省略してAPI節約：
  ```bash
  ./shutsujin_departure.sh -S
  ```
- 使わないときはtmuxセッションをデタッチ（`Ctrl+B` → `d`）
- bloom_routingをoffにすると動的モデル切替を無効化してシンプルに：
  ```yaml
  # settings.yaml に追加
  bloom_routing: "off"
  ```
