class Recording < ApplicationRecord
  self.table_name = "recording"

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

  # Validations, scopes, etc. can be added as needed
end