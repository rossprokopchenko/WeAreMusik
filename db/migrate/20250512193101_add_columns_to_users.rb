class AddColumnsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column "public.users", :username, :string
  end
end
