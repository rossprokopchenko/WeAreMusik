class CreateSavedReleases < ActiveRecord::Migration[8.0]
  def change
    create_table :saved_releases do |t|
      t.references :user, null: false, foreign_key: true
      
      # Store the release_id, but DO NOT add a foreign key constraint
      t.bigint :release_id, null: false

      t.timestamps
    end

    add_index :saved_releases, [:user_id, :release_id], unique: true
  end
end
