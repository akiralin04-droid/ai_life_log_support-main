# Day1

## 読んだファイル
- config/routes.rb

- app/controllers/sessions_controller.rb
- app/views/sessions/new.html.erb
- app/controllers/passwords_controller.rb
- app/views/passwords/new.html.erb
---
## このファイルの役割
- URLとControllerを紐付けるファイル
- アプリ全体の機能一覧を管理している
---
## 理解したこと
- routes.rb はURL管理
- controller users_controller.rbなど は処理管理
- model user.rbなど　はDB操作
- view top.html.erbなど　は画面表示
- schema.rb はDB設計図
- Gemfile はライブラリ管理

- "homes#top" = コントローラー名#アクション名
- root to: は最初に開くページ
- get "URL" => "コントローラー名#アクション名" = URLとコントローラーの紐付け
- as: "about" = URLのあだ名を指定 viewでabout_pathと書くだけでURLを呼び出せるようになる

- resource = ログイン情報（session）や自分の登録情報（registration）は、「ユーザー1人につき1つだけ」 = 単一リソース（URLにIDが不要なもの）
- resources 「ユーザー1人につき複数存在する」

- param: :token = URLにトークンを含めるための設定

- post = ユーザーからデータを受け取って状態変更をする（Create / Update / Delete）

- collection do 〜 end = コレクション全体に対する処理
- member do 〜 end = 個別(id付き)のみに対する処理

- 「入れ子（ネスト）」構造:resources : ① do の中に、さらに resources : ②「どの①に対する②なのか」がURLを見ただけで分かる
- module: :① 実際のファイルは app/controllers/①/②_controller.rb のように、フォルダの中に整理して置かれる

- namespace = 名前空間（ネームスペース）＝「管理者専用のルーティングですよ！」という意味 URL:/admin/usersなど コントローラーも admin/users_controller.rb のように、adminフォルダの中に整理される

- PWA =だのWebサイトを、スマホの「ネイティブアプリ（App Storeなどから入れるアプリ）」のように見せる最新技術
- manifest = マニフェストファイル（アプリの名前やアイコンなどを定義するファイル）
- service-worker = サービスワーカーファイル（オフラインでも動くようにするためのファイル）
---
## 処理の流れ（超重要）
- ユーザーがURLアクセス
↓
- routes.rb が Controller を呼ぶ
↓
- Controller が処理を実行
↓
- View を表示する
---
## 実際にやったこと
- routes.rb に日本語コメント追加
- controllerとviewを実際に開いて流れを確認
- resourcesの構造確認
---
## 感想
- routes.rb を読むことで、アプリ全体の構造がかなり見えやすくなった
- URL → Controller → Viewの流れが少し理解できた
---


## 次に読むファイル
- sessions_controller.rb