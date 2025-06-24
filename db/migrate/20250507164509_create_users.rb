class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table "public.users" do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false

      t.timestamps
    end
    add_index "public.users", :email_address, unique: true
  end
end
