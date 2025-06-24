
class CreateFollows < ActiveRecord::Migration[8.0]
  def change
    create_table "public.follows" do |t|
      t.references :follower, null: false, foreign_key: { to_table: "public.users" }
      t.references :followed, null: false, foreign_key: { to_table: "public.users" }

      t.timestamps
    end

    add_index "public.follows", [:follower_id, :followed_id], unique: true
  end
end
