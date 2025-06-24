class AddImageAuthorToArtists < ActiveRecord::Migration[8.0]
  def change
    add_column :artist, :image_author, :string
  end
end
