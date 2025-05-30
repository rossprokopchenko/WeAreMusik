class ArtistCreditName < ApplicationRecord
  self.table_name = "artist_credit_name"
  self.primary_key = :artist_credit, :position # composite primary key

  # Columns:
  # artist_credit : integer, not null (FK)
  # position      : integer, not null (part of PK)
  # artist        : integer, not null (FK)
  # name          : string(1024), not null
  # join_phrase   : string(255), not null

  belongs_to :artist_credit, foreign_key: "artist_credit"
  belongs_to :artist, foreign_key: "artist"

  validates :artist_credit, :position, :artist, :name, :join_phrase, presence: true
end
