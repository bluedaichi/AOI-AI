#!/usr/bin/env bash
# 使い方：bash .agents/skills/md-beautify/check.sh <ノートのパス>
# 直前に git に保存した版と今の版を比べ、消えた URL・[[リンク]]・数字を表示する。
set -u
f="${1:?ノートのパスを指定してください}"
cd "$(git rev-parse --show-toplevel)" || exit 1
rel=$(git -c core.quotepath=false ls-files --full-name -- "$f" | head -1)
[ -n "$rel" ] || { echo "git に保存された版がありません（新規ノートならチェック不要）"; exit 0; }

old=$(git show "HEAD:$rel" 2>/dev/null) || { echo "直前の版を読めません：$rel"; exit 1; }
new=$(cat "$f")

pick() { # $1=種類 $2=本文
  case "$1" in
    url)  printf '%s\n' "$2" | grep -oE 'https?://[^ )>]+' ;;
    link) printf '%s\n' "$2" | grep -oE '\[\[[^]]+\]\]' ;;
    num)  printf '%s\n' "$2" | grep -oE '[0-9][0-9,.]*' | sed -E 's/[,.]$//' ;;
  esac | sort -u
}

ng=0
for kind in url link num; do
  missing=$(comm -23 <(pick "$kind" "$old") <(pick "$kind" "$new"))
  if [ -n "$missing" ]; then
    ng=1
    case "$kind" in url) label="URL" ;; link) label="[[リンク]]" ;; num) label="数字" ;; esac
    echo "消えた${label}："
    printf '  %s\n' $missing
  fi
done
[ "$ng" -eq 0 ] && echo "OK：URL・リンク・数字はすべて残っています"
exit 0
