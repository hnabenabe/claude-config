# Self-Improving Skills アーキテクチャ設計書

## 概要

claude-configリポジトリを3分割し、エージェント・スキル定義に自己改善ループ（observe → inspect → amend → evaluate）を導入する。改善は「エージェント提案＋人間承認」方式で行う。

---

## 1. リポジトリ分割

### 3リポジトリ構成

#### claude-config（安定系 — 設定・インフラ）

変更頻度: 低。

```
claude-config/
├── CLAUDE.md, CLAUDE-{machine}.md
├── deploy.ps1             # 3リポジトリをpull & マージ
└── hooks/
```

#### claude-agents（進化系 — エージェント定義）

変更頻度: 中。「誰がやるか」を定義。

```
claude-agents/
├── README.md
├── coding/                # 開発チーム（7体）
│   ├── architect.md, implementer.md, tester.md
│   ├── infra.md, security.md, ops.md, pm.md
├── stakeholder/           # 病院ステークホルダーチーム（7体）
│   ├── end-user.md, comedical.md, nurse-manager.md
│   ├── doctor.md, medical-clerk.md, management.md, general-affairs.md
├── investigation/         # 調査チーム（4体）
│   ├── researcher.md, kakarichou.md, kakariin.md, auditor.md
├── logs/                  # Observe用
└── proposals/             # Amend用
```

#### claude-skills（進化系 — スキル定義）

変更頻度: 中。「どうやるか」を定義。

```
claude-skills/
├── README.md
├── IMPROVEMENT-LOOP.md
├── skills/
│   ├── team-dev/SKILL.md
│   ├── team-stakeholder/SKILL.md
│   └── team-investigation/SKILL.md
├── logs/
└── proposals/
```

### 分割の原則

- **claude-config**: 環境設定・hooks・デプロイ（安定）
- **claude-agents**: エージェント定義（進化。チーム別サブディレクトリ）
- **claude-skills**: オーケストレーション手順（進化。エージェントとは独立）
- 3リポジトリとも `sij-medinfo` org配下（private）

---

## 2. エージェント体制（18体・3チーム）

### coding（7体）

| エージェント | 役割 | model |
|------------|------|-------|
| architect | システム全体設計のレビュー・提案 | opus |
| implementer | コード品質・実装の具体的レビュー | sonnet |
| tester | テスト戦略・品質保証 | sonnet |
| infra | インフラ・ネットワーク構成評価 | sonnet |
| security | セキュリティ・ガイドライン準拠 | sonnet |
| ops | 運用・保守性・監視 | sonnet |
| pm | スコープ・スケジュール・リスク管理 | sonnet |

### stakeholder（7体）

| エージェント | 役割 | model |
|------------|------|-------|
| end-user | エンドユーザー目線の操作性評価 | sonnet |
| comedical | コメディカル部門の業務要件代弁 | sonnet |
| nurse-manager | 看護管理者の業務フロー評価 | sonnet |
| doctor | 医師の診療業務視点 | sonnet |
| medical-clerk | 医事課の運用・コスト評価 | sonnet |
| management | 経営層の投資判断視点 | sonnet |
| general-affairs | 総務・庶務の規程・調達評価 | sonnet |

### investigation（4体）

| エージェント | 役割 | model |
|------------|------|-------|
| researcher | 技術調査・代替案調査 | opus |
| kakarichou | 係長。調査計画の立案（実行しない） | opus |
| kakariin | 係員。個別調査タスクの正確な実行 | sonnet |
| auditor | 監査員。結果検証 + 自己改善ループ運用 | sonnet |

### スキルとエージェントの対応

| スキル | 使用エージェント | フロー |
|-------|-----------------|--------|
| team-dev | coding/ 7体 | 並列レビュー → 統合報告 |
| team-stakeholder | stakeholder/ 7体 | 並列レビュー → 統合報告 |
| team-investigation | investigation/ 4体 | 係長→係員(並列)→監査→報告 |

---

## 3. deploy.ps1 の改修

1. 3リポジトリをgit pull
2. claude-agents/ の全サブディレクトリのmdを `~/.claude/agents/` にフラットコピー
3. claude-skills/skills/ を `~/.claude/skills/` にコピー

リポジトリ上はチーム別整理、デプロイ先はフラット。

---

## 4. 自己改善ループ

### Observe（記録）

```jsonl
{
  "timestamp": "2026-03-17T10:30:00+09:00",
  "type": "agent",
  "name": "implementer",
  "category": "coding",
  "task_summary": "Pythonスクリプトのコードレビュー",
  "trigger": "ユーザー指示",
  "outcome": "success",
  "failure_reason": null,
  "user_feedback": null,
  "duration_seconds": 45,
  "model": "claude-sonnet-4-20250514",
  "related_files": ["coding/implementer.md"]
}
```

エージェントログ → claude-agents/logs/、スキルログ → claude-skills/logs/

### Inspect（分析）

auditorがログを分析し失敗傾向を検出。トリガー: 直近10回中3回以上failure、ユーザー指示、週次レビュー。

### Amend（修正提案）

auditorが proposals/ に改善提案を出力。人間がレビューするまで本体は変更しない。

### Evaluate（評価）

最低3回の実行結果で効果判断。改善なし or 新規failure → git revert。

---

## 5. 実装ステップ

| Phase | 内容 |
|-------|------|
| **1** | リポジトリ分割（claude-agents新規作成、claude-skills再構成） |
| **2** | Observe導入（ログ記録開始、フォーマット検証） |
| **3** | Inspect + Amend導入（auditor拡張、提案ワークフロー確立） |
| **4** | Evaluate導入（比較指標、ロールバック基準） |
| **5** | deploy.ps1改修（3リポジトリ対応） |

---

## 6. 注意事項

- ログにセンシティブ情報（患者データ等）を絶対に含めない
- proposals/ は必ず人間がレビューしてからマージ
- 自動マージは当面導入しない
- auditorにBash権限は付与しない（読み取り専門）
- エージェント追加時は既存との役割境界を確認し、1週間試用してから正式採用
