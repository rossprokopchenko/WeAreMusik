namespace :musicbrainz do
  desc "Create canonical_musicbrainz_data, canonical_recording_redirect, and canonical_release_redirect tables in musicbrainz DB, with indexes"
  task create_canonical_tables: :environment do
    config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: "musicbrainz").configuration_hash
    ActiveRecord::Base.establish_connection(config)
    connection = ActiveRecord::Base.connection

    puts "Creating tables in musicbrainz database..."

    # === canonical_musicbrainz_data ===
    unless connection.data_source_exists?(:canonical_musicbrainz_data)
      connection.create_table :canonical_musicbrainz_data do |t|
        t.integer :artist_credit_id
        t.text :artist_mbids
        t.text :artist_credit_name
        t.text :release_mbid
        t.text :release_name
        t.text :recording_mbid
        t.text :recording_name
        t.text :combined_lookup
        t.integer :score
      end
      puts "Created table: canonical_musicbrainz_data"
    else
      puts "Table canonical_musicbrainz_data already exists"
    end

    # Add index on release_mbid expression ::uuid for fast joins
    existing_indexes = connection.indexes(:canonical_musicbrainz_data).map(&:name)
    unless existing_indexes.include?("idx_canonical_musicbrainz_data_release_mbid_uuid")
      connection.execute <<~SQL
        CREATE INDEX idx_canonical_musicbrainz_data_release_mbid_uuid
        ON canonical_musicbrainz_data ((release_mbid::uuid))
      SQL
      puts "Created index: idx_canonical_musicbrainz_data_release_mbid_uuid"
    else
      puts "Index idx_canonical_musicbrainz_data_release_mbid_uuid already exists"
    end

    # === canonical_recording_redirect ===
    unless connection.data_source_exists?(:canonical_recording_redirect)
      connection.create_table :canonical_recording_redirect, id: false do |t|
        t.text :recording_mbid
        t.text :canonical_recording_mbid
        t.text :canonical_release_mbid
      end
      puts "Created table: canonical_recording_redirect"
    else
      puts "Table canonical_recording_redirect already exists"
    end

    # === canonical_release_redirect ===
    unless connection.data_source_exists?(:canonical_release_redirect)
      connection.create_table :canonical_release_redirect, id: false do |t|
        t.text :release_mbid
        t.text :canonical_release_mbid
        t.text :release_group_mbid
      end
      puts "Created table: canonical_release_redirect"
    else
      puts "Table canonical_release_redirect already exists"
    end

    puts "✅ Done creating canonical tables with indexes in musicbrainz database!"
  end
end
