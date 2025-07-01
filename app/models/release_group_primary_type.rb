class ReleaseGroupPrimaryType < MusicbrainzRecord
  self.table_name = "musicbrainz.release_group_primary_type"

  # Columns:
  # id           : integer, primary key
  # name         : string(100), not null, unique
  # parent       : integer (self reference)
  # child_order  : integer, default 0
  # description  : text
  # gid          : uuid, not null, unique

  has_many :child_types, class_name: "ReleaseGroupPrimaryType", foreign_key: "parent"
  belongs_to :parent_type, class_name: "ReleaseGroupPrimaryType", foreign_key: "parent", optional: true
end
