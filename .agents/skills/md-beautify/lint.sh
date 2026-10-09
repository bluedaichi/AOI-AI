#!/usr/bin/env bash
# 使い方：bash .agents/skills/md-beautify/lint.sh [ノートのパス ...]
# 引数なしなら、整形の対象フォルダ全体を調べる。書式に合わないノートだけ「パス：問題」を表示する（問題なしなら何も出さない）。
# 対象外：00_Inbox（生メモ）、40_Daily、90_Archive、30_Resources/me、10_Projects/*/drafts（記事本文）、
#         _agent・.agents・.claude・.obsidian、ルートの md、frontmatter に「beautify: false」があるノート
cd "$(git rev-parse --show-toplevel 2>/dev/null || dirname "$0")" || exit 0

in_scope() {
  case "$1" in
    10_Projects/*/drafts/*) return 1 ;;
    10_Projects/*|20_Areas/*|30_Resources/*) ;;
    *) return 1 ;;
  esac
  case "$1" in 30_Resources/me/*) return 1 ;; esac
  case "$1" in *.md) return 0 ;; esac
  return 1
}

check() {
  f="$1"; probs=""
  head -n 15 "$f" | grep -q '^beautify: *false' && return
  [ "$(head -c 3 "$f")" = "---" ] || probs="$probs frontmatterなし／"
  grep -q '^> \[!summary\]' "$f" || probs="$probs 結論(summary)なし／"
  # 4列以上の表
  # （コードブロック ``` の中は書式の例なので数えない）
  awk '/^(> )*```/ {code=!code; next} code {next} /^\|/ { s=$0; gsub(/\\\|/, "", s); if (split(s, a, "|") - 2 > 3) { found=1 } } END { exit !found }' "$f" && probs="$probs 4列以上の表あり／"
  # 「## 出典」より前の本文に URL リンクがある（脚注定義は除く）
  awk '/^(> )*```/ {code=!code; next} code {next} /^## 出典/ {exit} /^\[\^/ {next} /\]\(https?:/ {found=1} END {exit !found}' "$f" && probs="$probs 本文にURLあり（脚注へ）／"
  [ -n "$probs" ] && printf '%s：%s\n' "$f" "${probs%／}"
}

if [ $# -gt 0 ]; then
  for p in "$@"; do
    rel="${p#$(pwd)/}"
    [ -f "$rel" ] && in_scope "$rel" && check "$rel"
  done
else
  git -c core.quotepath=false ls-files -co --exclude-standard -- 10_Projects 20_Areas 30_Resources | while IFS= read -r rel; do
    in_scope "$rel" && check "$rel"
  done
fi
exit 0
