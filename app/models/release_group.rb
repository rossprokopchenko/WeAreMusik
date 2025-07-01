class ReleaseGroup < MusicbrainzRecord
  self.table_name = "musicbrainz.release_group"
  
  self.inheritance_column = nil

  has_many :releases
  belongs_to :primary_type, class_name: "ReleaseGroupPrimaryType", foreign_key: "type"
  belongs_to :artist_credit, foreign_key: "artist_credit", optional: true

  has_many :release_group_url_links, foreign_key: :entity0, class_name: 'ReleaseGroupUrlLink'
  has_many :external_urls, through: :release_group_url_links, source: :url
  
  # If you want to model the parent-child hierarchy of release_group types,
  # you can add associations for parent/child here later.
end
