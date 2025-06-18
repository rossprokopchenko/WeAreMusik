# app/models/label.rb
class Label < ApplicationRecord
  self.table_name = "label"

  # Disable Single Table Inheritance for the 'type' column,
  # as it's used as a foreign key and not for STI.
  self.inheritance_column = nil

  # Associations
  has_many :release_labels, foreign_key: :label # A label can be associated with many release_label entries
  has_many :releases, through: :release_labels # A label can have many releases through release_labels

  # Assuming 'type' is a foreign key to a LabelType model
  belongs_to :label_type, class_name: "LabelType", foreign_key: "type", optional: true

  # Assuming 'area' is a foreign key to an Area model
  belongs_to :area, foreign_key: "area", optional: true

  # Validations
  validates :gid, presence: true, uniqueness: true
  validates :name, presence: true
  validates :edits_pending, presence: true

end