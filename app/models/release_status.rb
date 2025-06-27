class ReleaseStatus < ApplicationRecord
  self.table_name = "musicbrainz.release_status"

  # Columns:
  # id          : integer, primary key
  # name        : string(100), not null, unique
  # parent      : integer (self reference)
  # child_order : integer, default 0, not null
  # description : text
  # gid         : uuid, not null, unique

  has_many :child_statuses, class_name: "ReleaseStatus", foreign_key: "parent"
  belongs_to :parent_status, class_name: "ReleaseStatus", foreign_key: "parent", optional: true

  has_many :releases, foreign_key: "status"
end
