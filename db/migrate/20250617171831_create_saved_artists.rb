
class CreateSavedArtists < ActiveRecord::Migration[8.0]
  def change
    create_table "public.saved_artists" do |t|
      t.references :user, null: false, foreign_key: true
      t.references :artist, null: false, foreign_key: { to_table: :artist }

      t.timestamps
    end

    add_index "public.saved_artists", [:user_id, :artist_id], unique: true
  end
end