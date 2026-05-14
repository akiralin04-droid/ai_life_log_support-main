# Day3-2

## 読んだ機能
ユーザー機能（プロフィール編集・アカウント削除）
---

## 読んだファイル
- config/routes.rb
- app/controllers/users_controller.rb
- app/views/users/edit.html.erb
- app/models/user.rb
- db/schema.rb
---

## 各ファイルの役割
- routes.rb：
URLとactionの対応を定義。resources（複数形）とresource（単数形）を使い分けている
- users_controller.rb：
編集・更新・削除の処理を担当。before_actionで事前処理を管理
- edit.html.erb：
プロフィール編集フォームの表示。エラーメッセージの表示も担当
- user.rb：
バリデーション・関連定義・ActiveStorage設定を担当
- schema.rb：
DBのカラム構造を定義
---

## 重要ポイント（これだけは覚えておく）
- @user と current_user は別物
@user　　　　→ URLの :id から取得したユーザー
current_user → セッションから取得したログイン中のユーザー
ensure_correct_user はこの2つを比較して本人以外を弾く
---

## 理解したこと
- before_actionの実行順が重要。
set_userが先に@userを作らないとensure_correct_userが使えない
- form_with model: @userはIDの有無でPOSTとPATCHを自動で切り替える
- render :editはリクエストを発生させないので@userのエラー情報が保持される
- profile_imageはusersテーブルにカラムがなく、ActiveStorageが別テーブルで管理する
- dependent: :destroyにより、@user.destroyの1行で関連データも全て削除される
- destroyルートが存在しないため退会ボタンは現時点では動作しない
---

## 処理の流れ
【画面表示】
GET /users/:id/edit
↓
set_user（@userをDBから取得）
↓
ensure_correct_user（本人確認）
↓
edit.html.erb 表示

【編集処理】
PATCH /users/:id
↓
set_user → ensure_correct_user
↓
user_params でフィルター
↓
@user.update
↓
成功：mypage_pathへリダイレクト
失敗：render :edit（エラーメッセージ表示）
---

## ファイルの繋がり
routes.rb
↓  URLとコントローラーを繋ぐ
users_controller.rb（before_action → action）
↓  set_user（@userをDBから取得）
edit.html.erb
↓  入力データを PATCH で送る
user.rb
↓  通過したらDBへ
schema.rb（usersテーブルに保存）
---

## Railsが自動でやっていること
- form_with model: @user → IDの有無でPOST/PATCHとURLを自動で決める
- has_one_attached → ActiveStorageが画像の保存・取得を管理する
- dependent: :destroy → 関連レコードを自動で一括削除する
- enum :role → general? / admin? などのメソッドを自動生成する
---

## 実際にやったこと
- routes.rb・users_controller.rb・edit.html.erb・user.rb・schema.rb を順番に読み、
わからない部分をAIに質問しながら処理の流れを追った
---

## 次に読むファイル
- app/controllers/mypages_controller.rb