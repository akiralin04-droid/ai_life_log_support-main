Rails.application.routes.draw do
  # トップページ & About
  root to: "homes#top"
  # root = アプリの入り口に設定
  # "homes#top" = コントローラー名#アクション名
  get "home/about" => "homes#about", as: "about"
  # get = ユーザーがブラウザで「この画面を見せて！」と**読み出し（Read）
  # get "URL" => "コントローラー名#アクション名" = URLとコントローラーの紐付け
  # as: "about" = URLのあだ名を指定　
  # するとviewでabout_pathと書くだけでURLを呼び出せるようになる



  # 利用規約 & プライバシーポリシー
  get "home/terms" => "homes#terms", as: "terms"
  get "home/privacy" => "homes#privacy", as: "privacy"

  # 検索
  get "search" => "searches#search"

  # 認証機能 (Rails 8 標準)
  resource :session
  resources :passwords, param: :token
  # resource と resources の違い（単数形 vs 複数形）
  # 通常は resources（複数形）
  # ログイン情報（session）や自分の登録情報（registration）は、「ユーザー1人につき1つだけ」
  # param: :token = パスワードリセットのURLにトークンを含めるための設定
  # 通常は/passwords/1 のように番号（ID）
  # 代わりに**「長くてランダムな文字列（token：トークン）」**をURLに使うためのセキュリティ設定


  # 新規登録 (カスタム)
  resource :registration, only: [:new, :create]

  # ゲストログイン (カスタム)
  post "session/guest_login" => "sessions#guest_login"
  # post = ユーザーからデータを受け取って状態変更をする（Create / Update / Delete）

  # ユーザー機能
  resources :users, only: [:index, :show, :edit, :update]
  # resources = [:index, :show, :new, :create,:edit, :update, :destroy]の中で必要なものだけを指定
  # index = ユーザーの一覧ページ
  # show = ユーザーの詳細ページ
  # new = ユーザー新規登録ページ
  # create = ユーザー新規登録処理
  # edit = ユーザーの編集ページ
  # update = ユーザーの情報を更新する処理
  # destroy = ユーザーの削除処理（今回は不要なので指定しない）

  # マイページ 
  resource :mypage, only: [:show]
  resources :weekly_reports, only:[:show, :create, :destroy]
  
  # 日記機能
  resources :diaries do
    collection do
      get :public_index # 「みんなの日記」用のアクション
    # collection do 〜 end （超重要！）
    # これがないと、public_indexは「/diaries/:id/public_index」のようなURLになってしまう
    # collection do 〜 end を使うと、「/diaries/public_index」のようなURLになる
    end
  end


  # レビュー機能 (AI生成含む)
  resources :reviews do
    collection do
      get :select_type 
      post :generate # AIによる下書き生成
    end
    # コメント・いいね (非同期)
    resources :comments, only: [:create, :destroy], module: :reviews
    resource :favorites, only: [:create, :destroy], module: :reviews
    # 「入れ子（ネスト）」構造:resources :reviews do の中に、さらに resources :comments 
    # 「どのレビューに対するコメントなのか」がURLを見ただけで分かる
    # POST /reviews/1/comments （＝1番のレビューに対してコメントを作成する！）
    # module: :reviews（プロの整理整頓術！）= 
    # 「このルーティングは、Reviewsコントローラーの中にCommentsコントローラーを作ってね！」という意味
    # 実際のファイルは app/controllers/reviews/comments_controller.rb のように、
    # フォルダの中に整理して置かれる

  end

  # AIチャット・インタビュー機能
  resources :ai_interviews, only: [:show, :create] do
    resources :ai_messages, only: [:create] # チャット内でメッセージを送信するため
    member do
    # member do 〜 end （超重要！）
    # member（メンバー＝特定の一員）は、**「特定の1つ（ID）を指定して、独自のURLを追加したい！」
    # 結果のURL: GET /ai_interviews/:id/finalize
      get :finalize  # 💡 追加 (自動遷移用)
      post :finalize # 💡 (ボタン用)
    end
  end

  # キャンペーン機能
  resources :campaigns, only: [:show]

  # 管理者機能 (Namespace)
  namespace :admin do
  # namespace = 名前空間（ネームスペース）＝「管理者専用のルーティングですよ！」という意味
  # これがないと、管理者用のURLも一般ユーザーと同じになってしまう
  # 結果のURL: /admin/users, /admin/reviews など
  # コントローラーも admin/users_controller.rb のように、adminフォルダの中に整理される
  # ユーザーと管理者のファイルを分けて整理しやすくする且つ、バグの際に事故が起きにくくなる
    get "/" => "dashboards#index"

    # ユーザー・レビュー・日記・キャンペーンの管理（resourcesにまとめる）
    resources :users, only:[:index, :show, :update]
    resources :reviews, only: [:index, :show, :destroy, :update]
    resources :diaries, only: [:index, :show, :destroy, :update]
    resources :campaigns
  end

  # オンボーディング完了用のルーティング（更新のみ）
  resource :onboarding, only: [:update]

  # PWA対応 (Rails 8 標準機能)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # PWA =だのWebサイトを、スマホの「ネイティブアプリ（App Storeなどから入れるアプリ）」
  # のように見せる最新技術
  # manifest = マニフェストファイル（アプリの名前やアイコンなどを定義するファイル）
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  #service-worker = サービスワーカーファイル（オフラインでも動くようにするためのファイル）

end