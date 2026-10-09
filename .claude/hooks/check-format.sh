#!/usr/bin/env bash
# PostToolUse(Write|Edit): 保存したファイルに応じて、Claude に次の作業を促す（exit 2 = Claude に伝える）
#  - ノート（.md）：md-beautify の書式に合っていなければ、整えさせる
#  - スキル（.agents/skills/*/SKILL.md）：説明ノートがなければ、作らせる
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
input=$(cat)
f=$(printf '%s' "$input" | grep -o '"file_path":"[^"]*"' | head -1 | sed -E 's/^"file_path":"//; s/"$//; s#\\\\#/#g')
[ -n "$f" ] && [ -f "$f" ] || exit 0
rel="${f#$(pwd)/}"

case "$rel" in
  .agents/skills/*/SKILL.md|.claude/skills/*/SKILL.md)
    name=$(grep -m1 '^name:' "$f" | sed -E 's/^name: *//')
    [ -n "$name" ] || exit 0
    if ! grep -rqs -- "$name" 30_Resources/スキル/; then
      printf '%s\n' "新しいスキル「$name」の説明ノートがありません。30_Resources/スキル/ に「$name（日本語の短い名前）.md」を md-beautify の書式で作り（何をするか・呼び出し方・使うとどうなるか・変わる前と後の例）、スキル一覧.md に1行足してください。" >&2
      exit 2
    fi
    exit 0 ;;
esac

out=$(bash .agents/skills/md-beautify/lint.sh "$f" 2>/dev/null)
if [ -n "$out" ]; then
  printf '%s\n%s\n' "$out" "md-beautify スキルの書式に合わせて、このノートを整えてください（中身は変えない。整えたら check.sh で確認）。" >&2
  exit 2
fi
exit 0
