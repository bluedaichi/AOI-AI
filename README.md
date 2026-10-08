# 自宅Vault ハーネス（MacBook Air ＋ Android）

職場とは完全に分けた、個人用の構成です。Mac を母艦にし、GitHub の非公開リポジトリを正本にします。

```
Android（Obsidian ＋ Obsidian Git） ─┐
                                     ├─ GitHub 非公開リポジトリ（正本）← クラウドの Claude / Codex もここで作業
Mac（Obsidian ＋ Obsidian Git） ─────┘
 └ Claude デスクトップ版・Codex デスクトップ版が Vault を直接編集（母艦）
Android の Claude アプリ ──Dispatch──→ Mac の Claude デスクトップ版
```

費用は0円です（Obsidian・Obsidian Git・GitHub の非公開リポジトリはすべて無料）。

## 1. 準備（Mac）
すでに入っているもの：Claude デスクトップ版、Codex デスクトップ版。追加で入れるもの：
1. Obsidian（無料）
2. git：ターミナルで `xcode-select --install`
3. GitHub のアカウント：github.com で「Continue with Google」から作成

## 2. GitHub の準備と配置（ターミナルのコマンドは1回だけ）
1. github.com 右上の「＋」→「New repository」→ 名前 `AOI-AI`、「Private」を選んで「Create repository」
2. 合言葉（トークン）を作る：右上アイコン → Settings → Developer settings → Personal access tokens → Fine-grained tokens → Generate new token
   - Repository access：Only select repositories → AOI-AI
   - Permissions：Contents を Read and write
   - 表示された `github_pat_…` をコピーしておく
3. zip を展開し、`AOI-AI` フォルダを「書類」に置く
4. ターミナルで `cd ~/Documents/AOI-AI && bash setup.sh`
   - ユーザー名と合言葉を聞かれるので入力（合言葉は Mac のキーチェーンに保存されます）
   - 「完了しました」と出れば成功
5. Obsidian で「フォルダを保管庫として開く」→ AOI-AI
6. 設定 → コミュニティプラグイン → 有効化 → 「Git」を入れて有効化
   - Auto commit-and-sync interval：10（分）
   - Pull on startup：ON

## 3. Android との同期（無料・GitHub 経由）
1. github.com → 右上アイコン → Settings → Developer settings → Personal access tokens → Fine-grained tokens → Generate new token
   - Repository access：Only select repositories → AOI-AI
   - Permissions：Contents を Read and write
   - 有効期限：1年。表示されたトークンはパスワード管理アプリなどに保存
2. Android に Obsidian を入れ、空の保管庫「AOI-AI」を作る
3. 設定 → コミュニティプラグイン → 制限モードをオフ → 「Git」を入れて有効化
4. コマンドパレット → 「Git: Clone an existing remote repo」
   - URL：`https://github.com/<ユーザー名>/AOI-AI.git`
   - ユーザー名：GitHub のユーザー名 / パスワード：手順1のトークン
   - 保管庫のルートに clone する
5. 自動同期を 10 分、起動時の取り込みを ON にする

注意：同じノートを Mac とスマホで同時に編集しない。スマホで書いたら同期（右下の Git アイコンか「Git: Commit-and-sync」）してから閉じる。

## 4. スマホから AI を使う（3通り）
| 状況 | 方法 | 何ができるか |
|---|---|---|
| Mac が起動中 | Android の Claude アプリ → Dispatch に「AOI-AI フォルダで Claude Code セッションを開いて、Inbox整理して」と送る | Mac のデスクトップ版が Vault を直接操作。終わると通知が届く |
| Mac が停止中 | Claude アプリの Code タブで GitHub の AOI-AI を選んで依頼 | 作業用ブランチと PR が届く。帰宅後に Mac でマージ |
| メモだけ | Obsidian で 00_Inbox/ に書いて同期 | あとで「Inbox整理して」で片付く |

Dispatch は Pro / Max プランで使えます。初回に Claude アプリと Mac のデスクトップ版をペアリングします。外出中は Mac を電源につなぎ、デスクトップ版の Settings → This computer → System で「Keep computer awake」を ON にします（蓋を閉じるとスリープします）。

## 5. 使い方の例
| やりたいこと | 言い方の例 |
|---|---|
| メモを整理 | 「Inbox整理して」 |
| 記事を書く | 「このメモを note 記事にしたい」→ 企画 → 構成 → 下書き → Codex レビュー |
| 点検 | 「点検して」 |
| 終わる | 「今日はここまで」→ 引き継ぎメモが更新されます |

## 6. このキットに入っている仕組み
| 種類 | 中身 | 役割 |
|---|---|---|
| 自己紹介 | 30_Resources/me/ | あなたの役割・優先順位・話し方の希望（最初に自分用に直す） |
| 地図 | AGENTS.md（Codex・Claude共通）／ CLAUDE.md（Claude専用の追記） | 毎回読む最小限のルール |
| スキル | note-draft / note-ideas / style-learn / research / compare / weekly-review / inbox-triage / review / vault-lint / handoff | 必要なときだけ読む手順書（.claude/skills は .agents/skills へのリンク） |
| 強制 | .claude/settings.json | 削除・強制push・.obsidian の編集を禁止 |
| 自動処理（.claude/hooks/） | 起動時に日付・Inbox件数・プロフィール・引き継ぎメモを読込／書き込み前に番号類をブロック／書き込み後に frontmatter 点検／確認待ちで通知／応答ごとに git へ自動保存 | 引き継ぎと履歴 |
| 評価 | Codex が review スキルで第三者チェック（CLI があれば自動、なければ Codex アプリで依頼） | 生成と評価の分離 |
| 衝突防止 | クラウドで動くときは main に直接書かずブランチ＋PR | 複数の場所から書いても壊れない |

## 7. 育て方
同じ失敗が2回起きたら、次のどれかを直します。
- 毎回守ってほしい短いルール → AGENTS.md
- 手順の改善 → 該当スキルの SKILL.md（note の文体は 30_Resources/me/文体ガイド.md に育てる）
- 絶対に起きてはいけないこと → settings.json の deny
AGENTS.md は100行以内を保ってください。

詳しい手順・プロンプト集・自律化の進め方は「AIハーネス セットアップガイド」を参照してください。
