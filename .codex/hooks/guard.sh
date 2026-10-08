#!/usr/bin/env bash
# PreToolUse(Write|Edit): 書いてはいけない番号を含む書き込みを止める（exit 2 = 中止）
input=$(cat | sed -E 's/"(session_id|transcript_path|tool_use_id|cwd)":"[^"]*"//g')
block() { printf '%s\n' "$1" >&2; exit 2; }
printf '%s' "$input" | grep -Eq '(^|[^0-9])[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}([^0-9]|$)' \
  && block "カード番号の可能性がある16桁の数字が含まれているため、書き込みを止めました。番号を伏せて書き直してください。"
printf '%s' "$input" | grep -Eq '(^|[^0-9])[0-9]{4} ?[0-9]{4} ?[0-9]{4}([^0-9]|$)' \
  && block "マイナンバー等の可能性がある12桁の数字が含まれているため、書き込みを止めました。番号を伏せて書き直してください。"
exit 0
