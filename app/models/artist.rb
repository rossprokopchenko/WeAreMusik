class Artist < ApplicationRecord
  include Meilisearch::Rails

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

  meilisearch do
    searchable_attributes %i[name]

    # Define attributes that can be used for filtering
    # filterable_attributes %i[]

    # Define attributes that can be used for sorting.
    # Useful for sorting by relevance, name, length, etc.
    sortable_attributes %i[name]

    # Attributes to display in search results.
    displayed_attributes %i[id name]
  
  end

end
