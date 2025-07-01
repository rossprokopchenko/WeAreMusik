class CreateLikedTracks < ActiveRecord::Migration[8.0]
  def change
    create_table :liked_tracks do |t|
      t.references :user, null: false, foreign_key: true
      
      # Store track_id as bigint (or UUID if that's the type in MusicBrainz) without FK constraint
      t.bigint :track_id, null: false

      t.timestamps
    end

    add_index :liked_tracks, [:user_id, :track_id], unique: true
  end
end
