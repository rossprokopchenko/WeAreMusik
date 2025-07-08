class AddUniqueIndexOnTurboStreamsId < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :turbo_streams, :id, unique: true, algorithm: :concurrently
  end
end