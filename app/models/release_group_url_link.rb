class ReleaseGroupUrlLink < ApplicationRecord
  self.table_name = 'musicbrainz.l_release_group_url'

  belongs_to :release_group, foreign_key: :entity0
  belongs_to :url, foreign_key: :entity1
end
