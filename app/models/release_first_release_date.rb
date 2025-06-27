class ReleaseFirstReleaseDate < ApplicationRecord
  self.table_name = "musicbrainz.release_first_release_date"

  # Associations
  belongs_to :release, foreign_key: :release, optional: true

  # Validations (optional, depending on your use)
  validates :release, presence: true

  def to_date
    Date.new(year || 1, month || 1, day || 1) rescue nil
  end
end
