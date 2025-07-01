class Recording < MusicbrainzRecord
  self.table_name = "musicbrainz.recording"

  belongs_to :artist_credit

  # Columns:
  # id : integer (primary key)
  # gid : uuid
  # name : text
  # artist_credit : integer (foreign key)
  # length : integer (duration in ms)
  # comment : text
  # edits_pending : integer, default 0
  # last_updated : timestamp
  # video : boolean, default false

  # Associations
  has_many :tracks

  has_many :recording_url_links, foreign_key: :entity0
  has_many :external_urls, through: :recording_url_links, source: :url


  # Validations, scopes, etc. can be added as needed
end