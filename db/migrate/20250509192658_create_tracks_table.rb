class CreateTracksTable < ActiveRecord::Migration[8.0]
  def change
    create_table :tracks do |t|
      t.string :track_id, index: { unique: true }
      t.string :artists, index: true
      t.string :album_name, index: true
      t.string :track_name, index: true
      t.integer :popularity
      t.integer :duration_ms
      t.boolean :explicit
      t.float :danceability
      t.float :energy
      t.integer :key
      t.float :loudness
      t.integer :mode
      t.float :speechiness
      t.float :acousticness
      t.string :instrumentalness
      t.float :liveness
      t.float :valence
      t.float :tempo
      t.integer :time_signature
      t.string :track_genre

      t.timestamps
    end
  end
end
