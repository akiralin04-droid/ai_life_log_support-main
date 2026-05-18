# Day7

## 読んだ機能
いいね機能（favorites）/ コメント機能（comments）※未実装確認
---

## 読んだファイル
- config/routes.rb（favorites・commentsのネスト部分）
- app/controllers/reviews/favorites_controller.rb
- app/views/reviews/favorites/_btn.html.erb
- app/models/favorite.rb
- app/models/review.rb（has_many :favorites部分）
- app/models/comment.rb
- db/schema.rb（favorites・commentsテーブル）
---

## 各ファイルの役割
- routes.rb 
reviews配下にfavoritesとcommentsをネストし、module: :reviewsでコントローラーのフォルダを指定
- favorites_controller.rb
いいねの作成・削除を担当。処理後にTurbo Streamでボタン部分だけ差し替える
- _btn.html.erb
ログイン状態・いいね済み状態によって表示するボタンを切り替えるpartial
- favorite.rb
userとreviewに属する。1ユーザー1いいねのバリデーションを持つ
- review.rb
has_many :favoritesとhas_many :commentsを持ち、dependent: :destroyで関連データを管理
- comment.rb
userとreviewに属する。controller・viewは未実装
- schema.rb
favoritesテーブル（user_id・review_id）、commentsテーブル（user_id・review_id・body）を定義
---

## 重要ポイント
- module: :reviewsでコントローラーをapp/controllers/reviews/フォルダに整理できる
- resource（単数）を使うことで「1レビューに1いいね」という設計をルーティングレベルで表現している
- Turbo StreamのtargetIDとviewのid属性を一致させることでボタン部分だけを差し替えられる
- exists?はオブジェクトを取得せずDBに問い合わせるためfind_byより軽い
- &.（ぼっち演算子）でnilの可能性があるオブジェクトへの呼び出しを安全に処理できる
- viewのexists?チェックとmodelのvalidatesの2重構造で重複いいねを防いでいる
- コメント機能はroutes・model・schemaは存在するがcontroller・viewが未実装
---

## 新しく出てきた概念
- Turbo Stream（turbo_stream.replace）：
ページ全体ではなく特定のDOM要素だけをサーバー側から差し替える仕組み
- &.（ぼっち演算子）：
nilの場合にメソッド呼び出しをスキップしてエラーを防ぐ演算子
- exists?：
レコードの存在をtrue/falseで返すActiveRecordメソッド。オブジェクトを取得しない分軽い
- module: :reviews（ルーティング）：
コントローラーをサブフォルダに整理するための名前空間指定
- uniqueness:{ scope: }：
特定の組み合わせに対して一意制約をかけるバリデーション
---

## 処理の流れ
【いいね登録】
POST /reviews/:review_id/favorites
↓
set_review（params[:review_id]でレビューを取得）
↓
@review.favorites.create(user_id: current_user.id)でDB保存
↓
turbo_stream.replace → "favorite_btn_#{@review.id}"を差し替え
↓
_btn.html.erbを再レンダリング（いいね済みボタンに変わる）

【いいね解除】
DELETE /reviews/:review_id/favorites
↓
set_review（params[:review_id]でレビューを取得）
↓
@review.favorites.find_by(user_id: current_user.id)で自分のいいねを特定
↓
favorite&.destroy（nilでもエラーにならない）
↓
turbo_stream.replace → "favorite_btn_#{@review.id}"を差し替え
↓
_btn.html.erbを再レンダリング（未いいねボタンに変わる）
---

## ファイルの繋がり
routes.rb
↓ reviews配下にresource :favoritesをネスト（module: :reviewsでフォルダ指定）

reviews/favorites_controller.rb（before_action :set_review → create / destroy）
↓ DB操作後にTurbo Streamでpartialを指定

reviews/favorites/_btn.html.erb（ログイン状態・いいね状態で表示切り替え）
↓ ボタン押下でPOST or DELETE送信

favorite.rb（validates uniqueness → 重複チェック）
↓ 通過したらDBへ

schema.rb（favoritesテーブルに保存）
---

## Railsが自動でやっていること
- resourcesのネストでparams[:review_id]を自動生成
- module: :reviewsでコントローラーのクラス名をReviews::FavoritesControllerに自動解決
- belongs_toで外部キーのバリデーションを自動実行
- dependent: :destroyで親レコード削除時に関連レコードを自動削除
---


## 次に読む機能
- 管理者機能