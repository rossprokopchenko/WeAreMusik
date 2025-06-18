
class CreateSavedReleases < ActiveRecord::Migration[8.0]
  def change
    create_table :saved_releases do |t|
      t.references :user, null: false, foreign_key: true
      t.references :release, null: false, foreign_key: { to_table: :release }

      t.timestamps
    end

    add_index :saved_releases, [:user_id, :release_id], unique: true
  end
end