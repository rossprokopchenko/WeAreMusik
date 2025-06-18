class ReleaseGroup < ApplicationRecord
  self.table_name = "release_group"
  
  self.inheritance_column = nil

  has_many :releases
  belongs_to :primary_type, class_name: "ReleaseGroupPrimaryType", foreign_key: "type"

  # If you want to model the parent-child hierarchy of release_group types,
  # you can add associations for parent/child here later.
end
