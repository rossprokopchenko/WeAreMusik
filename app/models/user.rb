class User < ApplicationRecord
  include Meilisearch::Rails

  require 'securerandom'

  def to_param
    gid.to_s
  end

  before_create :set_gid
  before_create :generate_verification_code

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  
  validates :email_address, presence: true, uniqueness: { case_sensitive: false }

  has_secure_password

  validates :password, presence: true, confirmation: true, length: { minimum: 8 }, if: :password_required?
  validate :password_complexity, if: :password_required?

  has_many :sessions, dependent: :destroy

  has_rich_text :biography
  
  has_one_attached :profile_picture
  validate :profile_picture_size_validation

  # Followers: users that follow this user
  has_many :follower_relationships, foreign_key: :followed_id, class_name: 'Follow', dependent: :destroy
  has_many :followers, through: :follower_relationships, source: :follower

  # Following: users this user is following
  has_many :followed_relationships, foreign_key: :follower_id, class_name: 'Follow', dependent: :destroy
  has_many :following, through: :followed_relationships, source: :followed

  has_many :saved_releases, dependent: :destroy
  # has_many :releases, through: :saved_releases, source: :release

  has_many :saved_artists, dependent: :destroy
  # has_many :artists, through: :saved_artists, source: :artist

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

  def saved_release_id?(release_id)
    saved_releases.exists?(release_id: release_id)
  end

  def saved_artist_id?(artist_id)
    saved_artists.exists?(artist_id: artist_id)
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

  def self.authenticate_by(username:, password:)
    find_by('LOWER(username) = ?', username.downcase)&.authenticate(password)
  end
  

  def generate_verification_code
    self.verification_code = SecureRandom.hex(3).upcase
    self.verified = false
  end

  def password_complexity
    return if password.blank?
  
    unless password.match?(/\A(?=.*[a-z])(?=.*\d).{8,}\z/)
      errors.add(:password, "must be at least 8 characters long and include at least one lowercase letter and one number.")
    end
  end
  
  # Only validate on create or when password is explicitly set
  def password_required?
    new_record? || !password.nil? || !password_confirmation.nil?
  end
end
