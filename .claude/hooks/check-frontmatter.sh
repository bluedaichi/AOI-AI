#!/usr/bin/env bash
# PostToolUse(Write|Edit): ノートに frontmatter がなければ Claude に直させる
input=$(cat)
f=$(printf '%s' "$input" | grep -o '"file_path":"[^"]*"' | head -1 | sed -E 's/^"file_path":"//; s/"$//; s#\\\\#/#g')
case "$f" in *.md) ;; *) exit 0 ;; esac
case "$f" in */00_Inbox/*|*/_agent/*|*/.agents/*|*/.claude/*|*/AGENTS.md|*/CLAUDE.md|*/README.md) exit 0 ;; esac
[ -f "$f" ] || exit 0
if [ "$(head -c 3 "$f")" != "---" ]; then
  printf '%s\n' "$f の先頭に frontmatter がありません。--- / created: YYYY-MM-DD / tags: [] / --- を付けてください。" >&2
  exit 2
fi
exit 0
