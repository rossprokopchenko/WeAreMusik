class RecordingUrlLink < ApplicationRecord
  self.table_name = "musicbrainz.l_recording_url"

  belongs_to :recording, foreign_key: :entity0
  belongs_to :url, foreign_key: :entity1
end
