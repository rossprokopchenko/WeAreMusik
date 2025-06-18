
class ReleaseCountry < ApplicationRecord
  self.table_name = "release_country"

  # Indicate that this table does not have a primary key column named 'id'.
  self.primary_key = nil

  # Associations
  belongs_to :release, foreign_key: :release

  belongs_to :country_area, class_name: "Area", foreign_key: :country

  # Validations
  # Ensure that each entry has both a release and a country.
  validates :release, presence: true
  validates :country, presence: true

  validates :country, uniqueness: { scope: :release, message: "already has a release date for this country" }

end
