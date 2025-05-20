require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WeAreMusik
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # config.logger = Logger.new(STDOUT)
    # config.logger = Log4r::Logger.new("Application Log")
    

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # if defined?(Rails::Server)
    #   config.after_initialize do
    #     fetchTracksObj = WeAreMusikAPI::Services::FetchTracks.new()

    #     trackResponse = fetchTracksObj.get_all_tracks
    #     new_tracks = []

    #     # puts trackResponse[:data].first

    #     trackResponse[:data].each_with_index do |track, index|
    #       new_track = Track.new(
    #         track_id: track[:track_id],
    #         artists: track[:artists],
    #         album_name: track[:album_name],
    #         track_name: track[:track_name],
    #         popularity: track[:popularity],
    #         duration_ms: track[:duration_ms],
    #         explicit: track[:explicit],
    #         danceability: track[:danceability],
    #         energy: track[:energy],
    #         key: track[:key],
    #         loudness: track[:key],
    #         mode: track[:mode],
    #         speechiness: track[:speechiness],
    #         acousticness: track[:acousticness],
    #         instrumentalness: track[:instrumentalness],
    #         liveness: track[:liveness],
    #         valence: track[:valence],
    #         tempo: track[:tempo],
    #         time_signature: track[:time_signature],
    #         track_genre: track[:track_genre],
    #       )
          
    #       new_tracks << new_track

    #       puts "Index: #{index}: Adding track #{track[:track_id]}"

    #     end

    #     result = Track.import(new_tracks, validate: true)

    #     puts "Import operation result: #{result}"

    #   end
    # end

  end
end
