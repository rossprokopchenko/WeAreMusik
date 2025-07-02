class CreateTurboStreams < ActiveRecord::Migration[8.0]
  def change
    create_table :turbo_streams do |t|
      t.string     :stream_name, null: false
      t.references :record, polymorphic: true, null: false
      t.string     :action, null: false
      t.text       :body, null: false
      t.timestamps
    end

    add_index :turbo_streams, [:stream_name, :record_type, :record_id, :action], unique: true, name: "index_turbo_streams_uniqueness"
  end
end
