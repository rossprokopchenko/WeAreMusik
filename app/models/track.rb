class Track < ApplicationRecord

  validates :track_id, uniqueness: true

  def self.ransackable_attributes(auth_object = nil)
    ["track_name", "album_name", "artists", "track_genre"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
