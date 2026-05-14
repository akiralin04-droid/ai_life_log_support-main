# Day3

## 読んだ機能
- 新規登録機能
---

## 読んだファイル
- config/routes.rb
- app/controllers/registrations_controller.rb
- app/views/registrations/new.html.erb
- app/models/user.rb
- db/schema.rb
---

## 各ファイルの役割
- routes.rb
URLとコントローラーを繋ぐ
- registrations_controller.rb
新規登録の処理を管理
- registrations/new.html.erb
新規登録画面のHTML（フォーム表示）
- user.rb
ユーザーデータのルール・関連・バリデーション定義
- schema.rb
DB全体の設計図。テーブル・カラム・制約を管理
---

## 重要ポイント
- roleは３層で守る
user_params に :role を含めない（第1層）
@user.role = 0 で強制上書き（第2層）
schema の default: 0（第3層）

- begin/rescueの二重防衛
第1の防衛：Railsのバリデーション（uniqueness: true）
第2の防衛：DBの制約（t.index unique: true）
同時アクセスなど稀なケースで第1をすり抜けた場合に第2が機能する

- User.new はフォームの設計図
① どのモデルか → name属性が user[xxx] になる
② 新規か既存か → POSTかPATCHか自動で決まる
③ エラーの入れ物 → バリデーション失敗時にエラーをviewに渡せる

- url: を明示する理由
model: @user だけだと /users に送ろうとする
ルートは /registration なので url: registration_path を明示する必要がある
---

## 理解したこと
- registrations_controller.rb はログインしていない人が使うため allow_unauthenticated_access が必要
- @user.save は「バリデーション実行」と「DB書き込み」を両方やる
- 保存成功後に start_new_session_for @user を呼ぶことで登録と同時に自動ログインする
- password_confirmation はhas_secure_passwordの予約語で、一致チェックが自動で行われる
- nameにバリデーションがないのは「空欄でも登録可」という意図的な設計
- local: true はAjaxを無効にして通常のページ遷移で動かすための設定
---

## 処理の流れ
【画面表示】
GET /registration/new
↓
routes →RegistrationsController#new
↓
@user = User.new（空の設計図を用意）
↓
new.html.erb 表示

【登録処理】
POST /registration
↓
RegistrationsController#create
↓
user_params（name / email_address / password / password_confirmation のみ通す）
↓
@user = User.new(user_params)（メモリ上にUserオブジェクトを作成）
↓
@user.role = 0（権限を強制的に一般ユーザーに設定）
↓
@user.save
↓
┌── バリデーション失敗
│   @user.errors にエラー追加
│   render :new → エラーメッセージ表示
│
├── DB重複エラー（rescue）
│   @user.errors に手動でエラー追加
│   render :new → エラーメッセージ表示
│
└── 保存成功
start_new_session_for @user（自動ログイン）
redirect_to root_path
---

## ファイルの繋がり
routes.rb
↓ URLとコントローラーを繋ぐ
registrations_controller.rb
↓ new → @user = User.new を渡す
new.html.erb（フォーム表示）
↓ 入力データを POST で送る
registrations_controller.rb
↓ user_params → @user.save
user.rb（バリデーション実行）
↓ 通過したらDBへ
schema.rb（usersテーブルに保存）
---

## Railsが自動でやっていること
- has_secure_password → パスワードをbcryptでハッシュ化 / password_confirmationの一致チェック
- enum :role → general? / admin? などのメソッドを自動生成
- normalizes :email_address → 保存前に小文字化・空白除去
- form_with model: @user → 送信先URL・HTTPメソッド・inputのname属性を自動で決める
---

## 実際にやったこと
- routes.rb で resource :registration の該当部分を確認した
- registrations_controller.rb を読んだ
- app/views/registrations/new.html.erb を読んだ
- app/models/user.rb を読んだ
- db/schema.rb のusersテーブル部分を読んだ
---


## 次に読むファイル
- app/controllers/users_controller.rb（ユーザー機能）