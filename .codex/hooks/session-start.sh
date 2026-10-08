#!/usr/bin/env bash
# SessionStart: 今日の状況・プロフィール・引き継ぎメモを最初に読み込ませる
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
today=$(date +%Y-%m-%d)
echo "今日: $today"
n=$(find 00_Inbox -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
echo "Inbox: ${n}件"
if [ -f "40_Daily/$today.md" ]; then echo "今日のデイリーノート: あり"; else echo "今日のデイリーノート: まだなし"; fi
for f in 30_Resources/me/*.md; do
  [ -f "$f" ] && { echo "--- $f ---"; head -n 60 "$f"; }
done
echo "--- _agent/progress.md ---"
cat _agent/progress.md 2>/dev/null
exit 0
