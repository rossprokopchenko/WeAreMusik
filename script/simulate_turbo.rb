# === EARLY INSERT_ALL MONKEY PATCH ===
puts "=== INSERT_ALL MONKEY PATCH ==="

module ActiveRecord
  class InsertAll
    alias_method :original_find_unique_index_for, :find_unique_index_for

    def find_unique_index_for(conflict_target)
      puts ">>> ActiveRecord::InsertAll#find_unique_index_for"
      puts "    conflict_target: #{conflict_target.inspect}"
      puts "    available unique indexes:"
      unique_indexes.each do |idx|
        puts "      #{idx.name} => columns: #{idx.columns.inspect}"
      end
      puts "--- CALLER TRACE ---"
      puts caller.take(20).join("\n")
      puts "--- END TRACE ---"
      original_find_unique_index_for(conflict_target)
    end
    
  end
end

puts "InsertAll monkey patch applied."
puts

# === DATABASE CONNECTION DEBUG ===
puts "=== DATABASE CONNECTION DEBUG ==="
puts

puts "ActiveJob adapter: #{ActiveJob::Base.queue_adapter.class.name}"
puts "ActiveJob queue_adapter inspect: #{ActiveJob::Base.queue_adapter.inspect}"

if ActiveJob::Base.queue_adapter.respond_to?(:queues)
  puts "ActiveJob queues: #{ActiveJob::Base.queue_adapter.queues.inspect}"
end

puts

puts "ApplicationRecord connection config:"
puts "  DB Config: #{ApplicationRecord.connection_db_config.inspect}"
puts "  Adapter: #{ApplicationRecord.connection_db_config.adapter}"
puts "  DB Name: #{ApplicationRecord.connection_db_config.name}"
puts "  Schema Search Path: #{ApplicationRecord.connection.schema_search_path}"
puts

puts "ActiveRecord Adapter: #{ApplicationRecord.connection.adapter_name}"
puts "Connection class: #{ApplicationRecord.connection.class.name}"
puts

if ApplicationRecord.connection.respond_to?(:raw_connection)
  raw_conn = ApplicationRecord.connection.raw_connection
  puts "Raw connection class: #{raw_conn.class.name}"
  if raw_conn.respond_to?(:host)
    puts "  Host: #{raw_conn.host}"
  end
  if raw_conn.respond_to?(:port)
    puts "  Port: #{raw_conn.port}"
  end
end

puts

%w[active_storage_blobs active_storage_attachments].each do |table|
  puts "Table: #{table}"
  indexes = ApplicationRecord.connection.indexes(table)
  indexes.each do |idx|
    puts "  Index: #{idx.name} | Unique: #{idx.unique} | Columns: #{idx.columns.inspect}"
  end
  puts
end

sample = Release.order("RANDOM()").limit(1).first
puts "Sample Release: ID=#{sample.id}, GID=#{sample.gid}" if sample

puts
puts "=== ACTIONCABLE BROADCAST TEST ==="
puts

if sample
  puts "Simulating ActionCable.server.broadcast..."
  puts "  Current connection before broadcast:"
  puts "    DB Config Name: #{ApplicationRecord.connection_db_config.name}"
  puts "    Adapter: #{ApplicationRecord.connection_db_config.adapter}"
  puts "    Adapter Class: #{ApplicationRecord.connection.class.name}"
  puts "    schema_search_path: #{ApplicationRecord.connection.schema_search_path}"

  begin
    html = ApplicationController.renderer.render(
      partial: "search/cover_art_frame",
      locals: { release: sample }
    )

    ActionCable.server.broadcast(
      "release_#{sample.gid}_cover_art",
      {
        target: "release_cover_art_#{sample.gid}",
        action: "replace",
        content: html
      }
    )

    puts "ActionCable broadcast simulated successfully."
  rescue => e
    puts "ActionCable broadcast ERROR: #{e.class}: #{e.message}"
    puts e.backtrace.take(10).join("\n")
  end
else
  puts "No sample Release found."
end

puts
puts "=== END DEBUG ==="
