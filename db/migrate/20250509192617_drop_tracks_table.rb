class DropTracksTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :tracks
  end
end
