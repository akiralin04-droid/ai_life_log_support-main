# Day5

## 読んだ機能
日記機能（CRUD全体）
---

## 読んだファイル
- config/routes.rb
- app/controllers/diaries_controller.rb
- app/views/diaries/new.html.erb
- app/views/diaries/edit.html.erb
- app/models/diary.rb
- db/schema.rb（diaries・reviews テーブル）
---

## 各ファイルの役割
- routes.rb：
/diaries/* のURLを DiariesController の各アクションに繋ぐ。
collection で /diaries/public_index を追加
- diaries_controller.rb：
日記のCRUD全体を管理。ensure_correct_user が @diary のセットと本人確認を兼任
- new.html.erb：
タブで2つの入力方法を切り替え。どちらのタブで送信するかで controller の分岐が変わる
- edit.html.erb：
フォームが2つある。AIに推敲依頼するフォームと、直接編集するフォーム。is_published の切り替えもここで行う
- diary.rb：
user・review・ai_interview との関連付けのみ。バリデーションなし（content は AI が生成するため）
- schema.rb：
content は NULL 許容、is_published は default: false、weekly_report_id は default なし（NULL）
---

## 重要ポイント
- ensure_correct_user 
@diary のセットと本人確認を1つのメソッドで担う
- current_user.diaries.find_by(id:) 
スコープを絞ることで、:id だけでは他人の日記にアクセスできない
- Diary.find_by(id:) 
id はプライマリーキーなので重複しない。user_id を重ねて検索することで他人の日記を弾く
- タブ1（音声）・タブ2（予定）は form が1つ。raw_voice_text に値があるかで controller の処理が分岐する
- content は最初 hidden_field で空文字のまま保存し、AI 生成後に update で上書きする設計
- has_one :review と has_many :reviews を両方書くことで、1件取得の便利さと全件削除の安全策を両立
- is_published は edit.html.erb のチェックボックスで初めて切り替えられる
- edit.html.erb にフォームが2つある理由：
AIに推敲依頼する処理と、直接編集する処理が別のアクションへ送信されるため
---

## 新しく出てきた概念
- collection：:id なしのカスタムルートを追加する（member は :id あり）
- スコープによる認可：current_user.diaries.find_by で「自分のものの中から探す」ことで他人の日記を弾く
- ぼっち演算子（&.）：current_user が nil でも .id でクラッシュせず nil を返す。ログアウト状態でも公開日記を表示できる設計のため必要
- local: true：Turbo を無効にして通常のページ全体遷移に戻す。別ページへリダイレクトする時に使う
- hidden_field：画面に表示しないが params に含めたい値を送る。purpose や diary_id の受け渡しにも使う
- フェイルセーフ：正常系では不要でも、異常系に備えて安全策を入れておく設計の考え方(has_one  :review と has_many :reviews, dependent: :destroy の話)
- アプリケーションレベルの制約：DB の unique index ではなく、処理フローで重複を防ぐ設計(１日記につき１レビューしか作成できない処理フロー)
- default: false / NULL：schema の default 指定の有無で、保存時の初期値が変わる
---

## 処理の流れ
【日記作成：音声ルート】
POST /diaries（raw_voice_text に値あり）
↓
current_user.diaries.build → user_id 自動セット
↓
@diary.save（content: "" で保存）
↓
raw_voice_text.present? → true
↓
ai_interview 作成 → finalize へリダイレクト
↓
AI が content を生成・@diary に上書き保存

【日記作成：予定ルート】
POST /diaries（schedule に値あり）
↓
@diary.save（content: "" で保存）
↓
raw_voice_text.present? → false
↓
OpenAI API で質問を生成 → ai_interview_path へリダイレクト
↓
AIチャット終了後に content を生成・@diary に上書き保存

【日記表示】
GET /diaries/:id
↓
Diary.find(params[:id])
↓
自分のもの OR is_published: true → 表示
それ以外 → diaries_path へリダイレクト

【日記編集：直接編集】
GET /diaries/:id/edit
↓
ensure_correct_user（@diary セット＋本人確認）
↓
edit.html.erb 表示
↓
PATCH /diaries/:id → @diary.update（content・is_published を更新）
↓
成功 → show へ / 失敗 → render :edit

【日記編集：AI推敲】
edit.html.erb で refinement_request を入力
↓
POST /ai_interviews（diary_id・purpose: diary_refinement を hidden_field で送信）
↓
推敲用の ai_interview が作成される → AIチャット画面へ

【日記削除】
DELETE /diaries/:id
↓
ensure_correct_user（@diary セット＋本人確認）
↓
@diary.destroy → reviews・ai_interviews も全削除
↓
mypage_path へリダイレクト
---

## ファイルの繋がり
【作成の流れ】
routes.rb
↓  GET /diaries/new → DiariesController#new
diaries_controller.rb（new）
↓  @diary = Diary.new（空の日記を用意）
diaries/new.html.erb
↓  タブ選択で入力 → POST /diaries
diaries_controller.rb（create）
↓  current_user.diaries.build → @diary.save
diary.rb / schema.rb（content: "" で diaries テーブルに保存）
↓  ai_interview を作成して別ページへ渡す
ai_interviews へ（Day6 で読む）

【編集の流れ】
routes.rb
↓  GET /diaries/:id/edit → DiariesController#edit
diaries_controller.rb（ensure_correct_user → edit）
↓  @diary をセット
diaries/edit.html.erb
↓  直接編集 → PATCH /diaries/:id → DiariesController#update
diary.rb / schema.rb（diaries テーブルを更新）
↓  AI推敲 → POST /ai_interviews（Day6 で読む）
---

## Railsが自動でやっていること
- resources :diaries で7つの RESTful ルートを自動生成
- form_with model: @diary（id なし）→ POST /diaries を自動判定
- form_with model: @diary（id あり）→ PATCH /diaries/:id を自動判定
- current_user.diaries.build → user_id を自動セット
- dependent: :destroy → @diary.destroy の1行で関連する reviews・ai_interviews も全削除
- weekly_report_id は default 指定なし → 保存時に自動で NULL
---


## 次に読む機能
AIインタビュー機能（ai_interviews）
