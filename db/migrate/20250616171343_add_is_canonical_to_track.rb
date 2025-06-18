class AddIsCanonicalToTrack < ActiveRecord::Migration[8.0]
  def change
    add_column :track, :is_canonical, :boolean, default: false, null: false
    add_index :track, :is_canonical
  end
end
