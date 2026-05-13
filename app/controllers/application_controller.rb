# ApplicationController = 全てのコントローラーの親クラス
# ActionController::Base = Railsのコントローラーの機能が入っているクラス
class ApplicationController < ActionController::Base
  # include Authentication = 認証機能を使えるようにする設定
  include Authentication
  # allow_browser versions: :modern = 古いブラウザを拒否する設定
  allow_browser versions: :modern
end
