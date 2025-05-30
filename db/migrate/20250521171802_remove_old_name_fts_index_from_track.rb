class RemoveOldNameFtsIndexFromTrack < ActiveRecord::Migration[8.0]
  def up
    remove_index :track, name: "index_tracks_on_name_fts"
  end

  def down
    execute <<-SQL
      CREATE INDEX index_tracks_on_name_fts ON track USING GIN (to_tsvector('english', name));
    SQL
  end
end