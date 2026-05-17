# Day6-3

## 読んだ機能
レビュー機能（reviews）
---

## 読んだファイル
・config/routes.rb
・app/controllers/reviews_controller.rb
・app/views/reviews/new.html.erb
・app/views/reviews/select_type.html.erb
・app/models/review.rb
・app/services/ai_review_generation_service.rb
・db/schema.rb（reviews・review_tags・tags・favorites・commentsテーブル）
---

## 各ファイルの役割
・routes.rb：
URLとアクションを繋ぐ。collection/ネスト/moduleで構造を整理
・reviews_controller.rb：
レビューのCRUDとAI下書き生成を担当
・new.html.erb：
AIの下書きをフォームに表示。ボタン2つで送信先を切り替える
・select_type.html.erb：
AIインタビュー開始前の入力画面
・review.rb：
関連・バリデーション・enum・ransack設定を定義
・ai_review_generation_service.rb：
OpenAIへの送信とレスポンス変換を担当
・schema.rb：
DBの実際のテーブル構造
---

## 重要ポイント
・before_actionでset_reviewをまとめると各アクションの同じ行が不要になる
・showはReview.find、edit/update/destroyはcurrent_user.reviews.findで権限を分ける
・generateはDBに保存せずrender :newでデータを引き継ぐ
・formactionでボタンごとに送信先を変えられる
・optional: trueとschemaのnull設定はセットで揃える必要がある
・AIにJSON形式で返すよう指定することでキー指定でデータを取り出せる
・rescue JSON::ParserError でAIの返答が壊れていても処理が止まらない
---

## 新しく出てきた概念
・Serviceオブジェクト：
長い処理をコントローラーから切り出す専用クラス。.callで実行
・has_many :through：
中間テーブル経由の多対多の関係
・enum：
DBに数字保存・Railsが名前に自動変換・?メソッドも使える
・self.category_options：
日本語表示と並び順を制御するクラスメソッド
・ransackable_attributes：
検索を許可するカラムを明示的に限定する
・formaction属性：
同じフォームでボタンごとに送信先を変える
・distinct: true：
ransackのJOINによる重複を除外する
・キーワード引数（default: nil）：
省略可能な引数の設計
・ヒアドキュメント <<~TEXT：
複数行文字列をすっきり書く
・.presence：
nil・空文字をまとめてnilに変換する
・response.dig：
ネストしたハッシュを安全に取り出す
・JSON.parse：
JSON文字列をRubyハッシュに変換する
---

## 処理の流れ
【AI下書き生成 → 新規投稿】
GET /reviews/select_type
↓
select_type.html.erb（詳細テキスト入力）
↓
POST /ai_interviews（AIインタビュー開始・Day6の処理へ）
↓
render reviews/new（@reviewにAI下書きデータが入った状態）
↓
POST /reviews → create → DBに保存
↓
成功 → show へ
失敗 → render :new（エラーメッセージ表示）

【直接投稿・編集・削除】
GET /reviews/new → new.html.erb → POST /reviews
GET /reviews/:id/edit → edit.html.erb → PATCH /reviews/:id
DELETE /reviews/:id → @review.destroy → reviews_pathへ
---

## ファイルの繋がり
routes.rb
↓ URLとコントローラーを繋ぐ

reviews_controller.rb（before_action → 各action）
↓ generateアクションからServiceを呼び出す

ai_review_generation_service.rb（OpenAI送信・JSONパース）
↓ ai_resultを返す

reviews/new.html.erb（hidden_fieldでデータをバケツリレー）
↓ フォーム送信

review.rb（validates・enum変換・has_many :through）
↓ 通過したらDBへ

schema.rb（reviewsテーブルに保存）
---

## Railsが自動でやっていること
・form_with model:@review（IDなし）→ POST /reviewsに自動で送る
・redirect_to @review → review_path(@review.id)を自動生成
・enum → DBの数字と名前の自動変換・?メソッドの自動生成
・belongs_to → optional: trueがない場合は必須バリデーションを自動実行
・dependent: :destroy → 親削除時に関連データを自動削除
---


## 次に読む機能
コメント・いいね機能（comments / favorites）