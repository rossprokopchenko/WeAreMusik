namespace :musicbrainz do
  desc "Add is_canonical column and all needed indexes to musicbrainz.track table"
  task add_is_canonical_to_tracks: :environment do
    config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: "musicbrainz").configuration_hash
    ActiveRecord::Base.establish_connection(config)
    connection = ActiveRecord::Base.connection

    puts "🔍 Checking track table..."

    # Add column if missing
    unless connection.column_exists?(:track, :is_canonical)
      puts "Adding column is_canonical..."
      connection.add_column :track, :is_canonical, :boolean, default: false, null: false
    else
      puts "Column is_canonical already exists."
    end

    existing_indexes = connection.indexes(:track).map(&:name)

    # Add index on is_canonical for fast filtering
    unless existing_indexes.include?("index_track_on_is_canonical")
      puts "Adding index on is_canonical..."
      connection.add_index :track, :is_canonical, name: "index_track_on_is_canonical"
    else
      puts "Index index_track_on_is_canonical already exists."
    end

    # Add compound index on (is_canonical, id) for range scans
    unless existing_indexes.include?("index_track_on_is_canonical_and_id")
      puts "Adding index on (is_canonical, id)..."
      connection.add_index :track, [:is_canonical, :id], name: "index_track_on_is_canonical_and_id"
    else
      puts "Index index_track_on_is_canonical_and_id already exists."
    end

    # Add index on medium for JOINs
    unless existing_indexes.include?("index_track_on_medium")
      puts "Adding index on medium..."
      connection.add_index :track, :medium, name: "index_track_on_medium"
    else
      puts "Index index_track_on_medium already exists."
    end

    puts "✅ Done patching track table!"
  end

  desc "Add is_canonical column and needed indexes to musicbrainz.release table"
  task add_is_canonical_to_releases: :environment do
    config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: "musicbrainz").configuration_hash
    ActiveRecord::Base.establish_connection(config)
    connection = ActiveRecord::Base.connection

    puts "🔍 Checking release table..."

    unless connection.column_exists?(:release, :is_canonical)
      puts "Adding column is_canonical..."
      connection.add_column :release, :is_canonical, :boolean, default: false, null: false
    else
      puts "Column is_canonical already exists."
    end

    existing_indexes = connection.indexes(:release).map(&:name)

    # Add index on is_canonical for filtering
    unless existing_indexes.include?("index_release_on_is_canonical")
      puts "Adding index on is_canonical..."
      connection.add_index :release, :is_canonical, name: "index_release_on_is_canonical"
    else
      puts "Index index_release_on_is_canonical already exists."
    end

    # Ensure unique index on gid for joins
    unless existing_indexes.include?("index_release_on_gid")
      puts "Adding unique index on gid..."
      connection.add_index :release, :gid, unique: true, name: "index_release_on_gid"
    else
      puts "Index index_release_on_gid already exists."
    end

    puts "✅ Done patching release table!"
  end

  desc "Add needed index to medium table for joins"
  task add_indexes_to_medium: :environment do
    config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: "musicbrainz").configuration_hash
    ActiveRecord::Base.establish_connection(config)
    connection = ActiveRecord::Base.connection

    puts "🔍 Checking medium table..."

    existing_indexes = connection.indexes(:medium).map(&:name)

    unless existing_indexes.include?("index_medium_on_release")
      puts "Adding index on release..."
      connection.add_index :medium, :release, name: "index_medium_on_release"
    else
      puts "Index index_medium_on_release already exists."
    end

    puts "✅ Done patching medium table!"
  end
end
