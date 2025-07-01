namespace :musicbrainz do
  desc "Safely initialize the musicbrainz database ONLY if it does NOT already exist"
  task :initialize, [:csv_dir] => :environment do |t, args|
    csv_dir = args[:csv_dir]

    puts "Creating canonical tables in musicbrainz database..."

    Rake::Task["musicbrainz:create_canonical_tables"].invoke
    Rake::Task["musicbrainz:create_canonical_tables"].reenable

    puts "✅ Finished creating canonical tables in musicbrainz database."

    puts "Importing canonical table data from '#{csv_dir}' into musicbrainz database..."

    Rake::Task["musicbrainz:import_canonical_data"].invoke(csv_dir)
    Rake::Task["musicbrainz:import_canonical_data"].reenable

    puts "✅ Finished importing canonical table data into musicbrainz database."

    puts "Adding 'is_canonical' column to tracks table in musicbrainz database..."

    Rake::Task["musicbrainz:add_is_canonical_to_tracks"].invoke
    Rake::Task["musicbrainz:add_is_canonical_to_tracks"].reenable

    puts "✅ Finished adding 'is_canonical' column to tracks table in musicbrainz database."

    puts "Adding 'is_canonical' column to releases table in musicbrainz database..."

    Rake::Task["musicbrainz:add_is_canonical_to_releases"].invoke
    Rake::Task["musicbrainz:add_is_canonical_to_releases"].reenable

    puts "✅ Finished adding 'is_canonical' column to releases table in musicbrainz database."

    puts "Adding indexes to medium table in musicbrainz database..."

    Rake::Task["musicbrainz:add_indexes_to_medium"].invoke
    Rake::Task["musicbrainz:add_indexes_to_medium"].reenable

    puts "✅ Finished adding indexes to medium table in musicbrainz database."

    puts "Backfilling the 'is_canonical' column in tracks table in musicbrainz database..."

    Rake::Task["musicbrainz:mark_canonical_tracks"].invoke
    Rake::Task["musicbrainz:mark_canonical_tracks"].reenable
    
    puts "✅ Finished backfilling the 'is_canonical' column in tracks table in musicbrainz database."

    puts "Backfilling the 'is_canonical' column in releases table in musicbrainz database..."

    Rake::Task["musicbrainz:mark_canonical_releases"].invoke
    Rake::Task["musicbrainz:mark_canonical_releases"].reenable

    puts "✅ Finished backfilling the 'is_canonical' column in releases table in musicbrainz database."
    
    puts "Creating the artist image column in musicbrainz database..."

    Rake::Task["musicbrainz:add_image_author_to_artist"].invoke
    Rake::Task["musicbrainz:add_image_author_to_artist"].reenable

    puts "✅ Finished creating the artist image column in musicbrainz database..."

    # Switch back to primary DB connection
    primary_config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: "primary").configuration_hash
    ActiveRecord::Base.establish_connection(primary_config)

    puts "✅ Finished initializing the musicbrainz database..."


  end
end

