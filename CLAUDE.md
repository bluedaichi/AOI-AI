@AGENTS.md

## Claude Code だけの追加ルール

### 役割
Claude Code は司令塔。計画・執筆・整理は自分で行い、第三者チェックは Codex に任せる。

### Codex へのレビュー依頼（生成と評価を分ける）
note の記事、公開する文章、お金が絡む判断材料を書き終えたら、次の手順で Codex に評価させる。

1. _agent/Tasks/YYYY-MM-DD-slug.md に依頼書を書く（対象ファイル、評価観点、出力先）。
2. 次のどちらかで Codex に処理させる。
   - Codex CLI がある場合（`command -v codex` で確認）：
     codex exec --sandbox workspace-write "AGENTS.md と _agent/Tasks/YYYY-MM-DD-slug.md を読み、review スキルに従って結果を _agent/Reports/YYYY-MM-DD-slug.md に書いて"
   - ない場合：ユーザーに「Codex アプリでこのフォルダを開き『_agent/Tasks の未処理の依頼を review スキルで処理して』と送ってください」と伝え、Reports ができるのを待つ。急ぐ場合や外出中（Dispatch 経由）は、サブエージェントに review スキルを実行させて代わりにする。
3. Reports を読み、指摘を反映するか判断して、その理由をユーザーに短く伝える。

### スマホから操作されているとき（Dispatch など）
返答は短くする（結論と次の一手だけ）。長い成果物はファイルに書き、ファイル名だけを伝える。

### セッションの終わり
作業が一区切りしたら handoff スキルで _agent/progress.md を更新する。
変更の保存（git commit）は Stop フックが自動で行う。GitHub への push は Obsidian Git が定期的に行うので、手動で push しなくてよい。
