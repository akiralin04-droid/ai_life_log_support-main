# Day2

## 読んだ機能
- ログイン機能（セッション管理）
---

## 読んだファイル
- app/controllers/sessions_controller.rb
- app/controllers/application_controller.rb
- app/controllers/concerns/authentication.rb
- app/views/sessions/new.html.erb
- app/models/user.rb
- db/schema.rb
---

## 各ファイルの役割
- sessions_controller.rb
ログイン・ログアウト・ゲストログインの処理を管理
- application_controller.rb
全コントローラーの親。Authenticationモジュールをinclude
- authentication.rb
セッション開始・終了・復元などログイン状態管理の実装
- sessions/new.html.erb
ログイン画面のHTML（フォーム表示）
- user.rb
ユーザーデータのルール・関連・バリデーション定義
- schema.rb
DB全体の設計図。テーブル・カラム・制約を管理
---

## 重要ポイント
- パスワードは絶対に生で保存しない
入力: "pass123"
↓ bcryptでハッシュ化（元に戻せない）
保存: "$2a$12$xK9z3m..."（password_digest）
照合: 入力値を同じルールでハッシュ化して比較する
     「復元」ではなく「同じ変換をかけて一致を確認」する

- ログイン状態はCookieとDBの2つで管理する理由
Cookieだけ → ユーザーが書き換えて他人になりすませる危険がある
DBだけ     → 「誰のセッションか」を識別する情報がサーバーに届かない
→ CookieでIDを送り、DBで照合することで安全に本人確認できる

- return はリダイレクト後の処理を止めるために書く
rubyunless user.is_active?
  redirect_to new_session_path
  return  # ← これがないと、この下のコードも実行されてしまう
end
start_new_session_for user  # returnがなければ凍結ユーザーでも実行される

- Railsの自動生成を信頼する
boolean カラム → ?メソッドが自動で使える（is_active?）
enum カラム    → admin? / general? が自動で使える
has_secure_password → authenticate_by が自動で使える
---

## 理解したこと
- sessions_controller.rb はログイン状態（セッション）の管理専門のコントローラー
- パスワードはDBに生のまま保存せず、bcryptでハッシュ化した password_digest として保存する
- ログイン状態は Cookie の session_id と DB の sessions テーブルで管理している
- return はredirect後の処理を止めるために必要。if/else では不要、unless の後ろにコードがある場合は必須
- params.permit はユーザー入力のフィルター。マスアサインメント攻撃を防ぐ
- rate_limit はブルートフォース攻撃（パスワード総当たり）への対策
- normalizes でメールアドレスを小文字化・空白除去してから保存する
- t.index unique: true はDBレベルの重複防止 + 検索高速化の2役
- Railsは boolean カラムを定義するだけで ? メソッドを自動生成してくれる
---

## 処理の流れ
【ログイン】
ブラウザで /session にアクセス（GET）
↓
routes → SessionsController#new
↓
sessions/new.html.erb 表示（フォーム）

メール・パスワードを入力 → ログインボタン押す
↓
POST /session → SessionsController#create
↓
params = { email_address: "xxx@gmail.com", password: "pass123" }
↓
params.permit でフィルター（セキュリティ）
↓
User.authenticate_by で認証
  → usersテーブルから email_address で検索
  → 入力パスワードをハッシュ化 → password_digest と比較
↓
認証失敗 → flash[:alert] → new画面へリダイレクト
認証成功 → Userオブジェクトを返す
↓
user.is_active? で凍結チェック（is_active カラム）
  false → flash[:alert] → new画面へリダイレクト（return）
  true  → 続行
↓
start_new_session_for(user)（authentication.rb のメソッド）
  → sessionsテーブルにレコード作成（user_id / ip / user_agent）
  → Current.session に保存
  → Cookie に session_id を保存（httponly / permanent）
↓
user.admin? で権限チェック（role カラム / enum）
  true  → admin_path へリダイレクト
  false → after_authentication_url へリダイレクト

【次のページアクセス時（セッション復元）】
ブラウザがCookieの session_id を送る
↓
before_action :require_authentication（全ページで動く門番）
↓
resume_session → find_session_by_cookie
  → sessionsテーブルから session_id で検索
  → Current.session に保存
↓
ログイン状態を復元 → ページ表示

【ログアウト】
DELETE /session → SessionsController#destroy
↓
terminate_session
  → DBのセッションレコード削除
  → CookieのセッションID削除
↓
root_path へリダイレクト
---

## ファイルの繋がり
application_controller.rb
  └── include Authentication
        ↓
  authentication.rb（モジュール）
        ├── start_new_session_for → sessionsテーブル作成 + Cookie保存
        ├── terminate_session     → sessionsテーブル削除 + Cookie削除
        ├── resume_session        → Cookieからセッション復元
        ├── after_authentication_url → ログイン後の遷移先
        └── require_authentication → 全ページの門番

sessions_controller.rb
  └── < ApplicationController（Authenticationの機能を全部使える）
        ├── create → User.authenticate_by → start_new_session_for
        ├── destroy → terminate_session
        └── guest_login → find_or_create_by! → start_new_session_for

sessions/new.html.erb
  └── form_with url: session_path → POST /session → create
      button_to session_guest_login_path → POST → guest_login

user.rb
  └── has_secure_password → authenticate_by を提供
      has_many :sessions  → user.sessions.create! を提供
      enum :role          → user.admin? を提供
      is_active（boolean）→ user.is_active? を自動生成

schema.rb（DB設計）
  └── users テーブル
        ├── password_digest（ハッシュ化パスワード）
        ├── role（0:一般 / 1:管理者）
        ├── is_active（true:有効 / false:停止）
        └── email_address（unique インデックス）
      sessions テーブル
        ├── user_id（外部キー）
        ├── ip_address
        └── user_agent
---

## Railsが自動でやっていること
- has_secure_password
パスワードのハッシュ化・authenticate_by メソッドの提供
- boolean カラム
is_active? などの ? メソッドを自動生成
- enum 
admin? / general? / admin! などのメソッドを自動生成
- created_at / updated_at
作成・更新日時をRailsが自動で記録
- before_action
全アクション実行前に自動でメソッドを呼び出す
- flash
リダイレクト先まで1回だけメッセージを持ち越す
- after_authentication_url
ログイン前のURLを記憶して、ログイン後に戻す
---

## 実際にやったこと
- sessions_controller.rb を読んで各 action の役割を確認した
- application_controller.rb を読んで Authentication モジュールの include を確認した
- authentication.rb を読んで start_new_session_for / terminate_session の実装を確認した
- sessions/new.html.erb を読んで form_with の送信先と params の流れを確認した
- user.rb を読んで has_secure_password / enum / has_many の関連を確認した
- schema.rb を読んで users / sessions テーブルの設計を確認した
---


## 次に読むファイル
- app/controllers/registrations_controller.rb（新規登録機能）