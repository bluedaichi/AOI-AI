#!/usr/bin/env bash
# Notification: Claude が確認待ちになったら Mac の通知を出す
osascript -e 'display notification "Claude Code が確認を待っています" with title "Claude Code"' >/dev/null 2>&1
exit 0
