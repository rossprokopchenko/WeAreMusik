class Url < ApplicationRecord
  self.table_name = "url"

  self.inheritance_column = nil

  # Assuming Url has a many-to-many relationship with ReleaseGroup
  has_many :release_group_url_links, foreign_key: :entity1, class_name: 'ReleaseGroupUrlLink'
  has_many :release_groups, through: :release_group_url_links, source: :release_group

  # If you want to add validations or methods, you can do so here.
  # For example:
  # validates :url, presence: true, format: { with: URI::regexp(%w[http https]) }

  # Assuming Url model
  # represents external URLs and each URL

  # has attributes like :id, :url
end
