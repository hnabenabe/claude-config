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
- Before running any technical command, explain IN JAPANESE:
  - What the command does (in plain language)
  - Expected outcome and impact
  - Any risks involved
- Ask「実行してよいですか？」before proceeding
- When in doubt, ask before executing

### Project Management
- C:\ClaudeWork\ 以下に新しいプロジェクトフォルダを作成した場合、C:\ClaudeWork\README.md の「現在のプロジェクト一覧」テーブルに追記すること
