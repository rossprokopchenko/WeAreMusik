
class CreateUserSocialLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :user_social_links do |t|
      t.references :user, null: false, foreign_key: true
      t.string :platform, null: false   # e.g. 'discord', 'spotify'
      t.string :url, null: false

      t.timestamps
    end

    add_index :user_social_links, [:user_id, :platform], unique: true
  end
end
