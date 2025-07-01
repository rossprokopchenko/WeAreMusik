namespace :musicbrainz do
  desc "Add image_author column to musicbrainz.artist table"
  task add_image_author_to_artist: :environment do
    # Load the musicbrainz DB config from database.yml for current environment
    musicbrainz_config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: "musicbrainz").configuration_hash

    # Switch connection to musicbrainz DB
    ActiveRecord::Base.establish_connection(musicbrainz_config)
    connection = ActiveRecord::Base.connection

    if connection.column_exists?(:artist, :image_author)
      puts "✅ Column artist.image_author already exists. Nothing to do!"
    else
      puts "➕ Adding image_author column to artist..."
      connection.add_column :artist, :image_author, :string
      puts "✅ Done! Column artist.image_author added."
    end

  end
end
