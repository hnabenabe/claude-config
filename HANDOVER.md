# HANDOVER

## 1. 完了した作業

- `claude-skills-split-instructions.md` に従い、1リポジトリ（multi-perspective-agents）→ 3リポジトリ構成への分割を実施
- **Step 1**: `claude-agents` リポジトリ新規作成（C:\ClaudeWork\tools\claude-agents）
  - coding（7体）: architect, implementer, tester, infra, security, ops, pm
  - stakeholder（7体）: end-user, comedical, nurse-manager, doctor, medical-clerk, management, general-affairs
  - investigation（4体）: researcher, kakarichou, kakariin, auditor（multi-perspective-agentsから移行）
- **Step 2**: `claude-skills` リポジトリ新規作成（C:\ClaudeWork\tools\claude-skills）
  - skills/team-dev/, skills/team-stakeholder/, skills/team-investigation/ の3スキル
  - IMPROVEMENT-LOOP.md（自己改善ループ仕様）新規作成
- **Step 3**: `~/.claude/` へのインストール
  - ~/.claude/agents/ に18エージェントをフラット配置
  - ~/.claude/skills/ に team-dev, team-stakeholder, team-investigation を追加
- **Step 4**: Git初期化 & GitHub push（hnabenabe アカウント、private）
  - https://github.com/hnabenabe/claude-agents
  - https://github.com/hnabenabe/claude-skills
- **Step 5**: 動作確認
  - `claude agents` で18体表示を確認
  - implementer サブエージェントでの単体テスト成功
- `C:\ClaudeWork\README.md` のプロジェクト一覧に claude-agents, claude-skills を追記

## 2. 判断事項

- **GitHub org**: 指示書では `sij-medinfo` org を想定していたが、gh CLI でアクセスできなかったため `hnabenabe` アカウントに private で作成
- **ソースリポジトリ**: `multi-perspective-agents`（6エージェント + 1スキル）を元に、investigation チームの4体を移行。coding/stakeholder の14体は新規作成
- **既存の critic.md, pragmatist.md**: multi-perspective-agents にあった2体は新体制に含まれないため移行せず
- **claude-skills のソース**: `claude-skills` ディレクトリが既存で存在しなかったため、完全新規作成

## 3. 問題と対応

- `claude-skills` リポジトリが指示書の「修正前」状態で存在しなかった → multi-perspective-agents から必要なファイルを取得し、新規構築する方針に切り替え
- `sij-medinfo` org にアクセス不可 → ユーザー確認の上 `hnabenabe` アカウントに作成
- Agent ツールで `implementer` サブエージェントタイプを直接指定できなかった → general-purpose エージェントで代替実行

## 4. 学んだこと

- Claude Code の Agent ツールの `subagent_type` はビルトインタイプのみ指定可能。ユーザー定義エージェントは `claude agents` コマンドで一覧は出るが、Agent ツールからの直接指定はできない
- `~/.claude/agents/` はフラット構造。リポジトリ側のサブディレクトリ構造はデプロイ時にフラット化する必要がある

## 5. 次のステップ

- [ ] `deploy.ps1` の改修: 3リポジトリ（claude-config, claude-agents, claude-skills）をpull & 統合配置する機能追加
- [ ] `sij-medinfo` org へのリポジトリ移管（アクセス設定後）
- [ ] 自己改善ループ Phase 2（Observe: ログ記録）の導入
- [ ] team-dev, team-stakeholder スキルの実践テスト（実際のPR/設計書でのチームレビュー）
- [ ] `.claude/settings.local.json` のローカル変更（未コミット）— 必要に応じて対応
- [ ] multi-perspective-agents リポジトリの扱い（アーカイブ or 削除）の判断

## 6. 主要ファイル

| ファイル | 状態 |
|---------|------|
| `C:\ClaudeWork\tools\claude-agents\` | 新規リポジトリ（18エージェント） |
| `C:\ClaudeWork\tools\claude-agents\coding\` | 新規（7体: architect〜pm） |
| `C:\ClaudeWork\tools\claude-agents\stakeholder\` | 新規（7体: end-user〜general-affairs） |
| `C:\ClaudeWork\tools\claude-agents\investigation\` | 移行（4体: researcher〜auditor） |
| `C:\ClaudeWork\tools\claude-skills\` | 新規リポジトリ（3スキル） |
| `C:\ClaudeWork\tools\claude-skills\skills\team-dev\SKILL.md` | 新規 |
| `C:\ClaudeWork\tools\claude-skills\skills\team-stakeholder\SKILL.md` | 新規 |
| `C:\ClaudeWork\tools\claude-skills\skills\team-investigation\SKILL.md` | 移行 |
| `C:\ClaudeWork\tools\claude-skills\IMPROVEMENT-LOOP.md` | 新規 |
| `~/.claude/agents/` | 18ファイル配置済み |
| `~/.claude/skills/team-dev/` | 配置済み |
| `~/.claude/skills/team-stakeholder/` | 配置済み |
| `~/.claude/skills/team-investigation/` | 配置済み |
| `C:\ClaudeWork\README.md` | 更新（プロジェクト一覧に追記） |
