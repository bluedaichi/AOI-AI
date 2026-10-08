#!/usr/bin/env bash
# 自宅Vault ハーネスの初期設定（Mac）
# 使い方：ターミナルで  cd ~/Documents/AOI-AI && bash setup.sh
# 事前に GitHub で「AOI-AI（Private）」と合言葉（トークン）を作っておくこと
set -u
cd "$(dirname "$0")" || exit 1

ok()   { printf '  ok  %s\n' "$1"; }
fail() { printf '\n!! %s\n' "$1"; exit 1; }

if [ -d _setup/claude ]; then
  echo "== 0. 設定ファイルを更新 =="
  mkdir -p .claude/hooks
  cp -R _setup/claude/. .claude/ && rm -rf _setup && ok ".claude を最新にしました"
fi

echo "== 1. フォルダを作成 =="
for f in 00_Inbox 10_Projects/note-shueki/drafts 20_Areas/移住検討 30_Resources 40_Daily 90_Archive _agent/Tasks _agent/Reports; do
  mkdir -p "$f" && touch "$f/.gitkeep" && ok "$f"
done

echo "== 2. スキルのリンク =="
if [ -e .claude/skills ] || [ -L .claude/skills ]; then
  ok "作成済み"
else
  ln -s ../.agents/skills .claude/skills && ok ".claude/skills -> .agents/skills"
fi

echo "== 3. 変更履歴（git）の準備 =="
command -v git >/dev/null 2>&1 || fail "git がありません。ターミナルで xcode-select --install を実行してから、もう一度 bash setup.sh を実行してください。"
if [ ! -d .git ]; then
  git init -q -b main || fail "git の準備に失敗しました。"
fi
git config user.name  >/dev/null || git config user.name  "AOI-AI"
git config user.email >/dev/null || git config user.email "AOI-AI@localhost"
git add -A
git diff --cached --quiet || git commit -q -m "init: harness"
ok "準備完了"

echo "== 4. GitHub につなぐ =="
if git remote get-url origin >/dev/null 2>&1 && GIT_TERMINAL_PROMPT=0 git ls-remote origin >/dev/null 2>&1; then
  ok "接続済み"
else
  echo
  printf 'GitHub のユーザー名を入力して Enter： '
  read -r GH_USER
  printf '合言葉（github_pat_ で始まる文字列）を貼り付けて Enter（画面には表示されません）： '
  read -rs GH_TOKEN; echo
  GH_USER=$(printf '%s' "$GH_USER" | tr -d '[:space:]')
  GH_TOKEN=$(printf '%s' "$GH_TOKEN" | tr -d '[:space:]')
  [ -n "$GH_USER" ] && [ -n "$GH_TOKEN" ] || fail "入力が空でした。もう一度 bash setup.sh を実行してください。"

  BASE="${HV_REMOTE_BASE:-https://github.com}"
  HOST="${BASE#https://}"
  git remote remove origin >/dev/null 2>&1
  if [ -x "$(git --exec-path)/git-credential-osxkeychain" ]; then
    # 合言葉は Mac のキーチェーンに保存する
    git remote add origin "https://$GH_USER@$HOST/$GH_USER/AOI-AI.git"
    git config credential.helper osxkeychain
    printf 'protocol=https\nhost=%s\nusername=%s\npassword=%s\n\n' "$HOST" "$GH_USER" "$GH_TOKEN" | git credential approve
  else
    git remote add origin "https://$GH_USER:$GH_TOKEN@$HOST/$GH_USER/AOI-AI.git"
  fi

  if ! GIT_TERMINAL_PROMPT=0 git ls-remote origin >/dev/null 2>&1; then
    fail "GitHub につながりませんでした。次を確認して、もう一度 bash setup.sh を実行してください。
   1) ユーザー名が正しいか（github.com の右上アイコンで確認できます）
   2) GitHub に「AOI-AI」という名前の保管場所を作ったか
   3) 合言葉の設定で AOI-AI を選び、Contents を Read and write にしたか"
  fi
  ok "接続できました"
fi

echo "== 5. GitHub に送る =="
GIT_TERMINAL_PROMPT=0 git push -q -u origin main 2>/dev/null || fail "送信に失敗しました。合言葉の Contents が Read and write になっているか確認してください。"
ok "送信完了"

cat <<'EOS'

完了しました。次は Obsidian で「書類」の AOI-AI を保管庫として開いてください。
（codex や gh が入っていなくても問題ありません）
EOS
