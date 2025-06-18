
class UserSocialLink < ApplicationRecord
  belongs_to :user

  validates :platform, presence: true, inclusion: { in: %w[discord spotify youtube soundcloud instagram twitter] }
  validates :url, presence: true
end
