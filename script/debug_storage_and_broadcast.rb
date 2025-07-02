
puts "=== DATABASE CONNECTION DEBUG ==="
puts

# Check current connection config for ActiveRecord
puts "ApplicationRecord connection: #{ApplicationRecord.connection_db_config.inspect}"
puts "ApplicationRecord schema_search_path: #{ApplicationRecord.connection.schema_search_path}"
puts

# Check ActiveStorage tables and indexes
%w[active_storage_blobs active_storage_attachments].each do |table|
  puts "Table: #{table}"
  indexes = ApplicationRecord.connection.indexes(table)
  indexes.each do |idx|
    puts "  Index: #{idx.name} | Unique: #{idx.unique} | Columns: #{idx.columns.inspect}"
  end
  puts
end

# Show a sample Release record
sample = Release.order("RANDOM()").limit(1).first
puts "Sample Release: ID=#{sample.id}, GID=#{sample.gid}" if sample

# Inspect the Turbo::StreamsChannel broadcast connection
puts
puts "=== TURBO BROADCAST TEST ==="
puts

if sample
  puts "Simulating Turbo::StreamsChannel.broadcast_replace_to..."
  puts "  Current connection before broadcast:"
  puts "    DB: #{ApplicationRecord.connection_db_config.name}"
  puts "    schema_search_path: #{ApplicationRecord.connection.schema_search_path}"

  begin
    Turbo::StreamsChannel.broadcast_replace_to(
      "release_#{sample.gid}_cover_art",
      target: "release_cover_art_#{sample.gid}",
      partial: "search/cover_art_frame",
      locals: { release: sample }
    )
    puts "Turbo broadcast simulated successfully."
  rescue => e
    puts "Turbo broadcast ERROR: #{e.class}: #{e.message}"
    puts e.backtrace.take(10).join("\n")
  end
else
  puts "No sample Release found."
end

puts
puts "=== END DEBUG ==="
