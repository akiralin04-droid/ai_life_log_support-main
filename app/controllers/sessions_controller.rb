# 親クラスの機能継承
class SessionsController < ApplicationController
  # allow_unauthenticated_access = ログインなしでもaction可能に設定
  allow_unauthenticated_access only: %i[ new create guest_login ]
  # rate_limit = 短時間に同じ処理を繰り返すのを防止 
  # 3分間に10回以上createアクションが呼び出されたら、警告を出してログイン画面にリダイレクトする設定
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "少し時間をおいて再度お試しください。" }

  # ログイン画面の表示
  def new
  end

  # ログイン処理
  def create
    # authenticate_by = メールアドレスとパスワードでユーザーを認証するメソッド
    # params = ユーザーから送られてきたデータ
    # .permit() = 指定した項目だけ受け取る設定 
    # ユーザーが入力した情報をadmin:trueなどにするのを防ぐ
    if user = User.authenticate_by(params.permit(:email_address, :password))
      # 凍結チェック
      unless user.is_active?
        redirect_to new_session_path, alert: "このアカウントは現在利用停止されています。お問い合わせください。"
        # return = ここで処理を終わらせる
        return
      end
      
      # ログイン成功時の分岐
      start_new_session_for user
      
      # 管理者ならダッシュボードへ
      if user.admin?
        redirect_to admin_path, notice: "管理者としてログインしました。"
      # 一般ユーザーなら本来行きたかったページ（またはTOP）へ
      else
        # after_authentication_url = ログイン前にアクセスしようとしたURLに移動
        redirect_to after_authentication_url, notice: "ログインしました。"
      end
    else
      redirect_to new_session_path, alert: "メールアドレスかパスワードが間違っています。"
    end
  end

  # ログアウト処理
  def destroy
    # terminate_session = セッションを破棄してログアウトする
    terminate_session
    redirect_to root_path, notice: "ログアウトしました。"
  end

  # ゲストログイン処理
  def guest_login
    # find_or_create_by! = メールアドレスが既に存在する場合はそのユーザーを返し、
    # 存在しない場合は新しくユーザーを作成して返す
    user = User.find_or_create_by!(email_address: 'guest@example.com') do |user|
      # SecureRandom.urlsafe_base64 = ランダムな文字列を生成 わざと誰もわからなくして操作できないようにする
      user.password = SecureRandom.urlsafe_base64
      user.name = "ゲストユーザー"
    end
    
    start_new_session_for user
    redirect_to root_path, notice: 'ゲストユーザーとしてログインしました。'
  end
end