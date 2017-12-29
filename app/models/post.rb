class Post < ApplicationRecord
  validates_presence_of :content
  belongs_to :user
  belongs_to :category, optional: true

  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user

  has_many :scores, class_name: 'PostScore'

  def find_like(user)
    likes.where(user_id: user.id).first
  end

  def find_score(user)
    user && scores.where(user_id: user.id).first
  end

  def average_score
    scores.average(:score)
  end
end
