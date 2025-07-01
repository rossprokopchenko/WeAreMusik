
class ReleaseLabel < MusicbrainzRecord
  self.table_name = "musicbrainz.release_label"

  # Associations
  belongs_to :release, foreign_key: :release
  belongs_to :label, foreign_key: :label

  # Validations
  validates :release, presence: true
  validates :label, presence: true

  validates :catalog_number, uniqueness: { scope: [:release, :label] }, allow_nil: true
end