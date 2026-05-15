class Diary < ApplicationRecord
  # belongs_to = 「このデータは、別のデータに所属してます」
  belongs_to :user
  belongs_to :weekly_report, optional: true

  # has_one = 「このデータは、別のデータを1つだけ持っています」
  # has_many = 「このデータは、別のデータを複数持っています」

  # 設計上1日記につき1レビューのみ生成される
  # has_one  → includes(:review) など1件取得で使用
  # has_many → アプリの使用上1つの日記では1つしかレビューが生まれない想定ですが、
  #            万が一複数できた場合も全件削除できる安全策
  has_one  :review
  has_many :reviews, dependent: :destroy

  has_many :ai_interviews, dependent: :destroy
  

  # Ransack用の検索・並び替え許可リスト
  def self.ransackable_attributes(auth_object = nil)["id", "is_published", "content", "emotion_score", "created_at"]
  end

  # Ransackで「関連するユーザー(user)」の情報も検索して良いと許可します
  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end

end