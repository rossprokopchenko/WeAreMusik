class ArtistType < ApplicationRecord
  self.table_name = "artist_type"

  has_many :artists, foreign_key: "type"
end
