class MusicbrainzRecord < ApplicationRecord
  self.abstract_class = true
  connects_to database: { writing: :musicbrainz_db }
end