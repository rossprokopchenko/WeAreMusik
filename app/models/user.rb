class User < ApplicationRecord
  include Meilisearch::Rails

  require 'securerandom'

  def to_param
    gid.to_s
  end

  before_create :set_gid
  
  has_secure_password

  has_many :sessions, dependent: :destroy

  has_rich_text :biography
  
  has_one_attached :profile_picture
  validate :profile_picture_size_validation

  has_many :follows, foreign_key: :follower_id, dependent: :destroy
  has_many :following, through: :follows, source: :followed

  has_many :reverse_follows, class_name: 'Follow', foreign_key: :followed_id, dependent: :destroy
  has_many :followers, through: :reverse_follows, source: :follower

  has_many :saved_releases, dependent: :destroy
  has_many :releases, through: :saved_releases, source: :release

  has_many :saved_artists, dependent: :destroy
  has_many :artists, through: :saved_artists, source: :artist

  has_many :liked_tracks, dependent: :destroy
  has_many :tracks, through: :liked_tracks

  has_many :user_social_links, dependent: :destroy
  accepts_nested_attributes_for :user_social_links, allow_destroy: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  meilisearch do
    searchable_attributes %i[ gid username ]

    # Define attributes that can be used for filtering
    # filterable_attributes %i[]

    # Define attributes that can be used for sorting.
    # Useful for sorting by relevance, name, length, etc.
    sortable_attributes %i[ username ]

    # Attributes to display in search results.
    displayed_attributes %i[ id username ]

  end

  private

  def set_gid
    # Assign a new UUID if 'gid' is not already set (e.g., if it's nil)
    self.gid ||= SecureRandom.uuid
  end

  def profile_picture_size_validation
    if profile_picture.attached? && profile_picture.blob.byte_size > 5.megabytes
      errors.add(:profile_picture, "is too big. Maximum size allowed is 5MB.")
    end
  end
end
