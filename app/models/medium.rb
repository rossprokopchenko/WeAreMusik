class Medium < MusicbrainzRecord
  self.table_name = "musicbrainz.medium"

  # Columns:
  # id            : integer, primary key
  # release       : integer, not null (FK)
  # position      : integer, not null
  # format        : integer
  # name          : string(255)
  # edits_pending : integer, default 0, not null
  # last_updated  : timestamp
  # track_count   : integer

  belongs_to :release, foreign_key: "release"
  belongs_to :format, class_name: 'MediumFormat', foreign_key: :format

  has_many :tracks, foreign_key: "medium"

  validates :release, :position, presence: true
end
