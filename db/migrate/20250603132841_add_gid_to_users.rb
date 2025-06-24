class AddGidToUsers < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!
  
  def change
    # Add the 'gid' column as a UUID type.
    # We'll allow it to be NULL initially so we can backfill existing users.
    # After backfilling, you might consider making it NOT NULL in a separate migration.
    add_column "public.users", :gid, :uuid, null: true

    # Add a unique index on the 'gid' column.
    # Using `algorithm: :concurrently` for large tables to avoid locking.
    puts "Starting to add a unique index on 'gid' to the 'users' table concurrently..."
    add_index "public.users", :gid, unique: true, algorithm: :concurrently
    puts "Finished adding the unique index on 'gid' to the 'users' table."
  end
end
