class AddVerificationFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column "public.users", :verification_code, :string
    add_column "public.users", :verified, :boolean
  end
end
