require 'csv'

namespace :musicbrainz do
  desc "Import canonical tables from CSV files in the given directory (pass dir path as argument) — lightning fast via COPY"
  task :import_canonical_data, [:csv_dir] => :environment do |t, args|
    csv_dir = args[:csv_dir]

    unless csv_dir
      puts "❌ Please provide a CSV directory. Example: rake musicbrainz:import_canonical_data['path/to/dir']"
      next
    end

    puts "📁 Using CSV directory: #{csv_dir}"

    config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: "musicbrainz").configuration_hash
    ActiveRecord::Base.establish_connection(config)
    connection = ActiveRecord::Base.connection.raw_connection # PG connection for COPY

    tables = {
      canonical_musicbrainz_data: 'canonical_musicbrainz_data.csv',
      canonical_recording_redirect: 'canonical_recording_redirect.csv',
      canonical_release_redirect: 'canonical_release_redirect.csv'
    }

    tables.each do |table_name, csv_file_name|
      csv_path = File.join(csv_dir, csv_file_name)

      unless File.exist?(csv_path)
        puts "⚠️  CSV file not found for #{table_name} at #{csv_path}, skipping..."
        next
      end

      model = Class.new(ActiveRecord::Base) do
        self.table_name = table_name.to_s
        self.inheritance_column = :_type_disabled
      end

      row_count_in_db = model.count
      if row_count_in_db > 0
        puts "⚠️  Skipping import for #{table_name} because table already contains #{row_count_in_db} rows."
        next
      end

      puts "⏳ Importing #{table_name} from #{csv_path} using COPY..."

      allowed_columns = model.column_names
      puts "✅ Allowed columns: #{allowed_columns.join(', ')}"

      # Prepare columns list for COPY — intersection of CSV headers & DB columns
      csv_headers = CSV.open(csv_path, 'r', &:readline)
      columns_to_copy = csv_headers & allowed_columns

      # Open CSV file again for COPY
      File.open(csv_path, 'r') do |file|
        # Skip headers for COPY because we specify columns explicitly
        file.readline if csv_headers.any?

        # Build COPY SQL command
        copy_sql = "COPY #{table_name} (#{columns_to_copy.join(',')}) FROM STDIN WITH CSV HEADER"

        connection.copy_data(copy_sql) do
          File.open(csv_path, 'r') do |file|
            # No manual header skipping here, just stream whole file
            file.each_line do |line|
              connection.put_copy_data(line)
            end
          end
        end
      end

      puts "🎉 Finished importing #{table_name}"
    end
  end
end
