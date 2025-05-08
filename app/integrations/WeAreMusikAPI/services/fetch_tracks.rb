module WeAreMusikAPI
  module Services
    class FetchTracks

      def initialize(params = {})
        # @platform_account = params[:platform_account]  
      end

      def perform(options = {})
        # Get a token
        # access_token_result = WeAreMusikAPI::Services::GetAccessToken.new({ platform_account: @platform_account })
        # return access_token_result if !access_token_result[:success]

        # Get Tracks from API
        # tracks_result = get_tracks(access_token_result[:data], options)
        tracks_result = get_tracks()
        if (tracks_result[:success] == false)
          return { success: false, errors: ["Could not get tracks from API"] }
        end

        tracks = map_tracks(tracks_result[:data])

        return { success: true, data: tracks }

      end

      private 
        # def get_tracks(access_token, options = {})
        def get_tracks(options = {})
          # WeAreMusikAPI::Tracks.new({ access_token: access_token }).list_channels({
          WeAreMusikAPI::Tracks.new().get_tracks({
            params: {

            }
          })
        end

        def map_tracks(raw_result)
          raw_tracks = raw_result || []

          tracks = raw_tracks.map do |raw_track|
            {
              # put the JSON parameters of each track returned from API here
              track_id: raw_track.dig(:track_id),
              artists: raw_track.dig(:artists),
              album_name: raw_track.dig(:album_name),
              track_name: raw_track.dig(:track_name),
              popularity: raw_track.dig(:popularity),
              duration_ms: raw_track.dig(:duration_ms),
              explicit: raw_track.dig(:explicit),
              danceability: raw_track.dig(:danceability),
              energy: raw_track.dig(:energy),
              key: raw_track.dig(:key),
              loudness: raw_track.dig(:loudness),
              mode: raw_track.dig(:mode),
              speechiness: raw_track.dig(:speechiness),
              acousticness: raw_track.dig(:acousticness),
              instrumentalness: raw_track.dig(:instrumentalness),
              liveness: raw_track.dig(:liveness),
              valence: raw_track.dig(:valence),
              tempo: raw_track.dig(:tempo),
              time_signature: raw_track.dig(:time_signature),
              track_genre: raw_track.dig(:track_genre),
            }
          end

          return tracks
        end

    end
  end
end
