class AddIsCanonicalToRelease < ActiveRecord::Migration[8.0]
  def change
    add_column :release, :is_canonical, :boolean, default: false, null: false
    add_index :release, :is_canonical
  end
end
