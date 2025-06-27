
class Area < ApplicationRecord
  self.table_name = "musicbrainz.area"
  self.primary_key = :id 

  # Disable Single Table Inheritance for the 'type' column,
  # as it's used as a foreign key to area_type and not for STI.
  self.inheritance_column = nil

  # Attributes mapped from the 'area' table:
  # id              : integer (now explicitly declared as PK)
  # gid             : uuid
  # name            : text
  # type            : integer (FK to area_type)
  # edits_pending   : integer
  # last_updated    : datetime (TIMESTAMPTZ in DB)
  # begin_date_year : integer
  # begin_date_month: integer
  # begin_date_day  : integer
  # end_date_year   : integer
  # end_date_month  : integer
  # end_date_day    : integer
  # ended           : boolean
  # dummy_extra_field : text (from previous import fix)

  # Associations
  # Assuming 'type' refers to an AreaType model
  belongs_to :area_type, class_name: "AreaType", foreign_key: "type", optional: true

  # An area can have many release_countries
  has_many :release_countries, foreign_key: "country"
  has_many :artists, foreign_key: "area"
  
  # An Area can have one corresponding CountryArea entry if it is classified as a country.
  # The foreign_key is 'area' because the 'country_area' table's primary key is 'area'.
  has_one :country_area, foreign_key: :area

  # Validations
  validates :gid, presence: true, uniqueness: true
  validates :name, presence: true
  validates :edits_pending, presence: true

  # Helper methods for dates
  def begin_date
    Date.new(begin_date_year, begin_date_month, begin_date_day) if begin_date_year && begin_date_month && begin_date_day
  rescue ArgumentError # Handles invalid dates like Feb 30th
    nil
  end

  def end_date
    Date.new(end_date_year, end_date_month, end_date_day) if end_date_year && end_date_month && end_date_day
  rescue ArgumentError
    nil
  end

  # Helper to check if the area is a country
  def is_country?
    country_area.present?
  end
end
