class Release < ApplicationRecord
  self.table_name = "release"

  # Columns:
  # id            : integer, primary key
  # gid           : uuid, not null
  # name          : text, not null
  # artist_credit : integer, not null (FK)
  # release_group : integer, not null (FK)
  # status        : integer (FK to release_status)
  # packaging     : integer (FK to release_packaging)
  # language      : integer
  # script        : integer
  # barcode       : text
  # comment       : text
  # edits_pending : integer, default 0, not null
  # quality       : integer
  # last_updated  : timestamp

  belongs_to :artist_credit, foreign_key: "artist_credit"
  belongs_to :release_group, foreign_key: "release_group"
  belongs_to :release_status, foreign_key: "status", optional: true
  belongs_to :release_packaging, foreign_key: "packaging", optional: true

  has_many :media, foreign_key: "release"

  validates :gid, :name, presence: true
end
