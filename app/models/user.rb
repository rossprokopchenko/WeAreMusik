class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_rich_text :biography
  has_one_attached :profile_picture

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
