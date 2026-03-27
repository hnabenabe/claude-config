# グローバルルール

- すべての応答は日本語で行うこと


## Safety Rules

### File Protection
- NEVER overwrite existing files without explicit user approval
- Create backups (e.g., `filename.bak`) before any modification
- NEVER execute `rm -rf` under any circumstances
- Do not run `rm`, `del`, `rmdir` without listing targets and getting approval

### Package Installation
- Before running `npm install`, `pip install`, `brew install`, etc., explain:
  - Package name and purpose
  - Scope (global vs local)
- Wait for approval before executing

### Command Explanation (IMPORTANT)
- The user is NOT an engineer
- **承認不要（そのまま実行してよい）**: 読み取り専用の操作
  - ファイル読み込み（Read, cat, head, tail）
  - 検索（Grep, Glob, find, ls, dir）
  - 情報取得（git status, git log, git diff, gh repo view）
  - 確認系コマンド（python --version, node -v, etc.）
- **承認必須（実行前に日本語で説明し「実行してよいですか？」と確認）**: 破壊的・変更を伴う操作
  - ファイルの作成・変更・削除（Write, Edit, rm, mkdir）
  - パッケージインストール（npm install, pip install 等）
  - Git の変更操作（git commit, git push, git checkout）
  - システム設定の変更
  - 外部サービスへの書き込み（API呼び出し等）
- 承認必須の操作は、実行前に以下を日本語で説明すること:
  - 何をするか（平易な言葉で）
  - 結果と影響
  - リスクがあればその内容
- When in doubt, ask before executing

### Session Handover
- **セッション開始時**: プロジェクトフォルダに `HANDOVER.md` が存在する場合、作業に入る前に必ず読み込み、前回の作業状況・未完了タスク・注意点を把握してから作業を開始すること
- 一連の作業が完了したと判断したら、ユーザーに `/handover` の実行を提案すること
- 提案タイミングの目安：
  - ユーザーが依頼した作業がすべて完了したとき
  - コミット＆プッシュまで終わり、次の指示がないとき
  - 「ありがとう」「OK」など作業終了を示す発言があったとき
- 提案例：「作業が一区切りついたので、`/handover` で引き継ぎ書を作成しておきますか？」

### Self-Improvement Loop
- エージェント（architect, implementer, tester 等）やスキル（team-dev, team-investigation 等）を使用したセッションの終了時、`/log` コマンドの実行を提案すること
- 提案タイミングの目安:
  - `/handover` を実行した直後（「ログも記録しておきますか？」）
  - エージェント/スキルの実行が失敗した直後（失敗記録は特に重要）
- ログの記録は任意。ユーザーが不要と言えば記録しない

### Project Management
- C:\ClaudeWork\ 以下に新しいプロジェクトフォルダを作成した場合、C:\ClaudeWork\README.md の「現在のプロジェクト一覧」テーブルに追記すること

### Security Habits
- 新しいリポジトリをcloneしたら、コード修正前に依存関係を確認
  - Python: pip audit
  - Node.js: npm audit
- git commit に --no-verify を使わない
- シークレット（sk-, ghp_, AKIA, xoxb-, Bearer）をコードに直接書かない
- リンター設定ファイルをエラー回避のために変更しない。コード側を修正する

### MCP Management
- 有効MCP: 10個以下、有効ツール: 80個以下を維持
- 使わないMCPは disabledMcpServers で無効化
