class User < ApplicationRecord
  # has_secure_password = パスワード管理の全自動機能
  # パスワードのハッシュ化、認証機能、バリデーションなど
  has_secure_password

  # validates = dbに保存して良いか判断するルール
  validates :email_address, presence: true, uniqueness: true
  
  # dependent: :destroy = ユーザーが削除されたときに紐づくデータも一緒に削除
  has_many :sessions, dependent: :destroy
  has_many :diaries, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :campaigns, dependent: :destroy # 管理者として作成したもの
  has_many :comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  # favorite_reviews = いいねしたレビューの情報を簡単に取得
  # through: :favorites = 「favoritesテーブルを経由して」という意味
  # source: :review = 「favoritesテーブルのreview_idを使って、reviews
  has_many :favorite_reviews, through: :favorites, source: :review
  has_many :ai_interviews, dependent: :destroy
  has_many :weekly_reports, dependent: :destroy

  # normalizes = データを保存する前に、特定のカラムの値を自動で整形する機能
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  
  # 画像設定
  # has_one_attached = ユーザーが1枚の画像をプロフィール画像としてアップロードできるようにする
  has_one_attached :profile_image

  # （0: 一般ユーザー、1: 管理者）
  enum :role, { general: 0, admin: 1 }

  # 👇 ここからRansack用の設定（差し替え）
  # Ransack = 検索と並び替えの機能を簡単に実装できる便利なGem
  # 1. 検索と並び替えを許可するカラムをすべて列挙します
  def self.ransackable_attributes(auth_object = nil)["id", "role", "is_active", "name", "email_address", "created_at"]
  end

  # 2. 検索を許可する関連テーブル（今回は使わないので空にする）
  def self.ransackable_associations(auth_object = nil)
    []
  end

end