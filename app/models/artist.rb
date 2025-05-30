class Artist < ApplicationRecord
  self.table_name = "artist"
  self.inheritance_column = :_type_disabled
  
  # Columns:
  # id               : integer, primary key
  # gid              : uuid, not null
  # name             : text, not null
  # sort_name        : text, not null
  # begin_date_year  : smallint (optional)
  # begin_date_month : smallint (optional)
  # begin_date_day   : smallint (optional)
  # end_date_year    : smallint (optional)
  # end_date_month   : smallint (optional)
  # end_date_day     : smallint (optional)
  # type             : integer (possibly referencing artist type)
  # area             : integer (foreign key to area table?)
  # gender           : integer (gender classification)
  # comment          : text, default ''
  # edits_pending    : integer, default 0, not null
  # last_updated     : timestamp
  # ended            : boolean, default false, not null
  # extra_metric_1   : integer (nullable)
  # extra_metric_2   : integer (nullable)

  # Associations
  has_many :artist_credit_names
  has_many :artist_credits, through: :artist_credit_names

  # Validations
  validates :gid, presence: true
  validates :name, presence: true
  validates :sort_name, presence: true

  # You can add enums or references if needed for type, area, gender
  
  # Scopes or methods for dates could be added, e.g., to get full begin/end dates
end
