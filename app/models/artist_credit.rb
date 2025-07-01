class ArtistCredit < MusicbrainzRecord
  self.table_name = "musicbrainz.artist_credit"

  # Columns:
  # id            : integer, primary key
  # name          : string(1024), not null
  # artist_count  : integer, not null
  # ref_count     : integer, not null
  # created       : timestamp with time zone, not null
  # edits_pending : integer, default 0, not null
  # gid           : uuid, not null, unique

  has_many :artist_credit_names, foreign_key: "artist_credit", dependent: :destroy
  has_many :artists, through: :artist_credit_names

  validates :name, :artist_count, :ref_count, :created, :gid, presence: true
end
