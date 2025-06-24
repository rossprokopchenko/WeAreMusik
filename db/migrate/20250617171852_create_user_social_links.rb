
class CreateUserSocialLinks < ActiveRecord::Migration[8.0]
  def change
    create_table "public.user_social_links" do |t|
      t.references :user, null: false, foreign_key: true
      t.string :platform, null: false   # e.g. 'discord', 'spotify'
      t.string :url, null: false

      t.timestamps
    end

    add_index "public.user_social_links", [:user_id, :platform], unique: true
  end
end
