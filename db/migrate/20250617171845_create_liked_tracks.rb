
class CreateLikedTracks < ActiveRecord::Migration[8.0]
  def change
    create_table :liked_tracks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :track, null: false, foreign_key: { to_table: :track }

      t.timestamps
    end

    add_index :liked_tracks, [:user_id, :track_id], unique: true
  end
end