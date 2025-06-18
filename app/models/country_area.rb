
class CountryArea < ApplicationRecord
  self.table_name = "country_area"

  # Since the table only has one column 'area' and it's a foreign key
  # acting as the primary key, we explicitly set primary_key.
  self.primary_key = :area
  # For some older Rails versions or specific adapters, you might also need:
  # self.id = false
  # self.incrementing_primary_key = false

  # Associations
  # A CountryArea record "belongs to" an Area, as its 'area' column
  # is a foreign key referencing the 'id' of the Area table.
  belongs_to :area, foreign_key: :area

  # Validations
  # Ensure the 'area' column is present and unique, as it's the primary key.
  validates :area, presence: true, uniqueness: true
end
