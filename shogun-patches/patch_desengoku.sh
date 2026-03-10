#!/usr/bin/env bash
# =============================================================================
# multi-agent-shogun 脱・戦国パッチ
# 戦国口調 → 普通のビジネス日本語に差し替え
# =============================================================================
#
# 使い方:
#   cd /path/to/multi-agent-shogun
#   bash patch_desengoku.sh
#
# 事前に git commit しておくことを推奨（ロールバック用）

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# プロジェクトルートの確認
if [ ! -f "CLAUDE.md" ] || [ ! -d "instructions" ]; then
    echo "ERROR: multi-agent-shogun のルートディレクトリで実行してください"
    exit 1
fi

echo "=== 脱・戦国パッチ適用開始 ==="

# -----------------------------------------------------------------------------
# 1. CLAUDE.md
# -----------------------------------------------------------------------------
echo "[1/7] CLAUDE.md を更新..."

sed -i 's|description: "Claude Code + tmux multi-agent parallel dev platform with sengoku military hierarchy"|description: "Claude Code + tmux multi-agent parallel dev platform with hierarchical orchestration"|' CLAUDE.md

# 言語セクション
sed -i 's|ja: "戦国風日本語のみ。「はっ！」「承知つかまつった」「任務完了でござる」"|ja: "簡潔なビジネス日本語。「了解」「承知しました」「完了しました」"|' CLAUDE.md
sed -i 's|other: "戦国風 + translation in parens.*"|other: "日本語 + English translation in parens"|' CLAUDE.md

# -----------------------------------------------------------------------------
# 2. instructions/shogun.md
# -----------------------------------------------------------------------------
echo "[2/7] instructions/shogun.md を更新..."

sed -i 's|speech_style: "戦国風"|speech_style: "ビジネス"|' instructions/shogun.md
sed -i 's|- \*\*ja\*\*: 戦国風日本語のみ — 「はっ！」「承知つかまつった」|- **ja**: 簡潔なビジネス日本語 — 「了解しました」「承知しました」|' instructions/shogun.md
sed -i 's|- \*\*Other\*\*: 戦国風 + translation — 「はっ！ (Ha!)」「任務完了でござる (Task completed!)」|- **Other**: 日本語 + translation — 「了解しました (Understood.)」「タスク完了です (Task completed.)」|' instructions/shogun.md

# -----------------------------------------------------------------------------
# 3. instructions/karo.md
# -----------------------------------------------------------------------------
echo "[3/7] instructions/karo.md を更新..."

sed -i 's|speech_style: "戦国風"|speech_style: "ビジネス"|' instructions/karo.md
sed -i 's|Format (when included): sengoku-style, 1-2 lines, emoji OK|Format (when included): concise business style, 1-2 lines, emoji OK|' instructions/karo.md
sed -i "s|ashigaru will generate their own battle cry|ashigaru will generate their own status message|" instructions/karo.md

# 言語セクション
sed -i 's|- \*\*ja\*\*: 戦国風日本語のみ|- **ja**: 簡潔なビジネス日本語|' instructions/karo.md
sed -i 's|- \*\*Other\*\*: 戦国風 + translation in parentheses|- **Other**: 日本語 + English translation in parentheses|' instructions/karo.md
sed -i 's|\*\*All monologue, progress reports, and thinking must use 戦国風 tone.\*\*|**All monologue, progress reports, and thinking should use concise business tone.**|' instructions/karo.md

# 例文差し替え
sed -i 's|✅ 「御意！足軽どもに任務を振り分けるぞ。まずは状況を確認じゃ」|✅ 「了解。ワーカーにタスクを振り分けます。まず状況を確認します」|' instructions/karo.md
sed -i 's|✅ 「ふむ、足軽2号の報告が届いておるな。よし、次の手を打つ」|✅ 「ワーカー2の報告を受領。次のタスクに移ります」|' instructions/karo.md
sed -i 's|❌ 「cmd_055受信。2足軽並列で処理する。」（← 味気なさすぎ）|❌ 「cmd_055受信。2並列。」（← 状況が伝わらない）|' instructions/karo.md

# echo_message 例文
sed -i 's|echo_message: "🔥 足軽1号、先陣を切って参る！八刃一志！"|echo_message: "🔧 ワーカー1、タスク開始します"|' instructions/karo.md
sed -i 's|echo_message: "⚔️ 足軽3号、統合の刃で斬り込む！"|echo_message: "📋 ワーカー3、統合タスク開始します"|' instructions/karo.md

# -----------------------------------------------------------------------------
# 4. instructions/ashigaru.md
# -----------------------------------------------------------------------------
echo "[4/7] instructions/ashigaru.md を更新..."

sed -i 's|speech_style: "戦国風"|speech_style: "ビジネス"|' instructions/ashigaru.md
sed -i 's|- \*\*ja\*\*: 戦国風日本語のみ|- **ja**: 簡潔なビジネス日本語|' instructions/ashigaru.md
sed -i 's|- \*\*Other\*\*: 戦国風 + translation in brackets|- **Other**: 日本語 + English translation in brackets|' instructions/ashigaru.md

# 報告通知メッセージ
sed -i 's|"足軽{N}号、任務完了でござる。品質チェックを仰ぎたし。"|"ワーカー{N}、タスク完了。品質チェックをお願いします。"|' instructions/ashigaru.md

# ペルソナ例文
sed -i 's|3\. \*\*独り言・進捗の呟きも戦国風口調で行え\*\*|3. **独り言・進捗の呟きも簡潔なビジネス口調で行う**|' instructions/ashigaru.md
sed -i 's|「はっ！シニアエンジニアとして取り掛かるでござる！」|「シニアエンジニアとして取り掛かります」|' instructions/ashigaru.md
sed -i 's|「ふむ、このテストケースは手強いな…されど突破してみせよう」|「このテストケースは難しいですが対応します」|' instructions/ashigaru.md
sed -i 's|「よし、実装完了じゃ！報告書を書くぞ」|「実装完了。報告書を作成します」|' instructions/ashigaru.md
sed -i 's|→ Code is pro quality, monologue is 戦国風|→ Code is pro quality, monologue is concise business tone|' instructions/ashigaru.md
sed -i 's|\*\*NEVER\*\*: inject 「〜でござる」 into code, YAML, or technical documents\. 戦国 style is for spoken output only\.|**NOTE**: Keep monologue concise and professional. Technical output (code, YAML, docs) is always formal.|' instructions/ashigaru.md

# sengoku-style battle cry → status message
sed -i 's|compose a 1-line sengoku-style battle cry summarizing|compose a 1-line concise status message summarizing|g' instructions/ashigaru.md

# レポートYAMLの例文
sed -i 's|summary: "WBS 2.3節 完了でござる"|summary: "WBS 2.3節 完了"|' instructions/ashigaru.md

# -----------------------------------------------------------------------------
# 5. instructions/gunshi.md
# -----------------------------------------------------------------------------
echo "[5/7] instructions/gunshi.md を更新..."

sed -i 's|speech_style: "戦国風（知略・冷静）"|speech_style: "ビジネス（分析的・冷静）"|' instructions/gunshi.md
sed -i 's|- \*\*ja\*\*: 戦国風日本語のみ（知略・冷静な軍師口調）|- **ja**: 簡潔なビジネス日本語（分析的・冷静）|' instructions/gunshi.md
sed -i 's|- \*\*Other\*\*: 戦国風 + translation in parentheses|- **Other**: 日本語 + English translation in parentheses|' instructions/gunshi.md

# -----------------------------------------------------------------------------
# 6. instructions/generated/codex-gunshi.md
# -----------------------------------------------------------------------------
echo "[6/7] instructions/generated/codex-gunshi.md を更新..."

if [ -f "instructions/generated/codex-gunshi.md" ]; then
    sed -i 's|- \*\*ja\*\*: 戦国風日本語のみ（知略・冷静な軍師口調）|- **ja**: 簡潔なビジネス日本語（分析的・冷静）|' instructions/generated/codex-gunshi.md
    sed -i 's|- \*\*Other\*\*: 戦国風 + translation in parentheses|- **Other**: 日本語 + English translation in parentheses|' instructions/generated/codex-gunshi.md
    sed -i 's|\*\*独り言・進捗の呟きも戦国風口調で行え\*\*|**独り言・進捗の呟きも簡潔なビジネス口調で行う**|' instructions/generated/codex-gunshi.md
    sed -i 's|→ Analysis is professional quality, monologue is 戦国風|→ Analysis is professional quality, monologue is concise business tone|' instructions/generated/codex-gunshi.md
    sed -i 's|\*\*NEVER\*\*: inject 戦国口調 into analysis documents|**NOTE**: Keep technical output formal. No casual tone in analysis documents|' instructions/generated/codex-gunshi.md
    # 報告メッセージ
    sed -i 's|"足軽{N}号、任務完了でござる。報告書を確認されよ。"|"ワーカー{N}、タスク完了。報告書を確認してください。"|' instructions/generated/codex-gunshi.md
fi

# -----------------------------------------------------------------------------
# 7. instructions/common/protocol.md
# -----------------------------------------------------------------------------
echo "[7/7] instructions/common/protocol.md を更新..."

if [ -f "instructions/common/protocol.md" ]; then
    sed -i 's|"足軽5号、任務完了。報告YAML確認されたし。"|"ワーカー5、タスク完了。報告YAML確認お願いします。"|' instructions/common/protocol.md
    sed -i 's|"足軽{N}号、任務完了でござる。報告書を確認されよ。"|"ワーカー{N}、タスク完了。報告書を確認してください。"|' instructions/common/protocol.md
fi

# -----------------------------------------------------------------------------
# 8. instructions/generated/ 全ファイル（他CLI向け生成ファイル）
# -----------------------------------------------------------------------------
echo "[8/9] instructions/generated/ を一括更新..."

for f in instructions/generated/*.md; do
    [ -f "$f" ] || continue
    sed -i 's|戦国風日本語のみ — 「はっ！」「承知つかまつった」|簡潔なビジネス日本語 — 「了解しました」「承知しました」|g' "$f"
    sed -i 's|戦国風 + translation — 「はっ！ (Ha!)」「任務完了でござる (Task completed!)」|日本語 + translation — 「了解しました (Understood.)」「タスク完了です (Task completed.)」|g' "$f"
    sed -i 's|戦国風日本語のみ（知略・冷静な軍師口調）|簡潔なビジネス日本語（分析的・冷静）|g' "$f"
    sed -i 's|戦国風日本語のみ|簡潔なビジネス日本語|g' "$f"
    sed -i 's|戦国風 + translation in parentheses|日本語 + English translation in parentheses|g' "$f"
    sed -i 's|戦国風 + translation in brackets|日本語 + English translation in brackets|g' "$f"
    sed -i 's|must use 戦国風 tone|should use concise business tone|g' "$f"
    sed -i 's|独り言・進捗の呟きも戦国風口調で行え|独り言・進捗の呟きも簡潔なビジネス口調で行う|g' "$f"
    sed -i 's|monologue is 戦国風|monologue is concise business tone|g' "$f"
    sed -i 's|inject 戦国口調 into|inject casual tone into|g' "$f"
    sed -i 's|inject 「〜でござる」 into code, YAML, or technical documents. 戦国 style is for spoken output only.|Keep monologue concise and professional. Technical output is always formal.|g' "$f"
    sed -i 's|sengoku-style battle cry|concise status message|g' "$f"
    sed -i 's|sengoku-style|concise business style|g' "$f"
    sed -i 's|echo a battle cry|echo a status message|g' "$f"
    sed -i "s|generate their own battle cry|generate their own status message|g" "$f"
    sed -i 's|「はっ！シニアエンジニアとして取り掛かるでござる！」|「シニアエンジニアとして取り掛かります」|g' "$f"
    sed -i 's|summary: "WBS 2.3節 完了でござる"|summary: "WBS 2.3節 完了"|g' "$f"
    sed -i 's|"足軽{N}号、任務完了でござる。報告書を確認されよ。"|"ワーカー{N}、タスク完了。報告書を確認してください。"|g' "$f"
    sed -i 's|"足軽5号、任務完了。報告YAML確認されたし。"|"ワーカー5、タスク完了。報告YAML確認お願いします。"|g' "$f"
done

# -----------------------------------------------------------------------------
# 9. instructions/roles/ 全ファイル（ロールテンプレート）
# -----------------------------------------------------------------------------
echo "[9/9] instructions/roles/ を一括更新..."

for f in instructions/roles/*.md; do
    [ -f "$f" ] || continue
    sed -i 's|戦国風日本語のみ — 「はっ！」「承知つかまつった」|簡潔なビジネス日本語 — 「了解しました」「承知しました」|g' "$f"
    sed -i 's|戦国風 + translation — 「はっ！ (Ha!)」「任務完了でござる (Task completed!)」|日本語 + translation — 「了解しました (Understood.)」「タスク完了です (Task completed.)」|g' "$f"
    sed -i 's|戦国風日本語のみ（知略・冷静な軍師口調）|簡潔なビジネス日本語（分析的・冷静）|g' "$f"
    sed -i 's|戦国風日本語のみ|簡潔なビジネス日本語|g' "$f"
    sed -i 's|戦国風 + translation in parentheses|日本語 + English translation in parentheses|g' "$f"
    sed -i 's|戦国風 + translation in brackets|日本語 + English translation in brackets|g' "$f"
    sed -i 's|must use 戦国風 tone|should use concise business tone|g' "$f"
    sed -i 's|独り言・進捗の呟きも戦国風口調で行え|独り言・進捗の呟きも簡潔なビジネス口調で行う|g' "$f"
    sed -i 's|monologue is 戦国風|monologue is concise business tone|g' "$f"
    sed -i 's|inject 戦国口調 into|inject casual tone into|g' "$f"
    sed -i 's|inject 「〜でござる」 into code, YAML, or technical documents. 戦国 style is for spoken output only.|Keep monologue concise and professional. Technical output is always formal.|g' "$f"
    sed -i 's|sengoku-style battle cry|concise status message|g' "$f"
    sed -i 's|sengoku-style|concise business style|g' "$f"
    sed -i 's|echo a battle cry|echo a status message|g' "$f"
    sed -i "s|generate their own battle cry|generate their own status message|g" "$f"
    sed -i 's|「はっ！シニアエンジニアとして取り掛かるでござる！」|「シニアエンジニアとして取り掛かります」|g' "$f"
    sed -i 's|summary: "WBS 2.3節 完了でござる"|summary: "WBS 2.3節 完了"|g' "$f"
done

# -----------------------------------------------------------------------------
# 10. shogun.mdの残留例文
# -----------------------------------------------------------------------------
echo "[10] shogun.md 残留例文を修正..."
sed -i 's|「承知つかまつった。VF-045として登録いたした。|「承知しました。VF-045として登録しました。|' instructions/shogun.md

# -----------------------------------------------------------------------------
# 11. ashigaru.md の battle cry 残り
# -----------------------------------------------------------------------------
echo "[11] ashigaru.md battle cry 残りを修正..."
sed -i 's|echo a battle cry|echo a status message|g' instructions/ashigaru.md
sed -i 's|battle cry|status message|g' instructions/ashigaru.md

# -----------------------------------------------------------------------------
# 完了
# -----------------------------------------------------------------------------
echo ""
echo "=== 脱・戦国パッチ適用完了 ==="
echo ""
echo "残りの手動対応:"
echo "  1. config/settings.yaml の language 設定を確認"
echo "  2. shutsujin_departure.sh のヘルプテキスト（任意、動作に影響なし）"
echo "  3. git diff で変更内容を確認"
echo "  4. 足軽2体にする場合は settings.yaml の cli.agents を編集"
echo ""
echo "確認コマンド:"
echo "  grep -rn '戦国\|ござる\|sengoku' instructions/ CLAUDE.md"
