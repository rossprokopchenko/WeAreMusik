class FetchArtistImageJob < ApplicationJob
  queue_as :default

  def perform(artist_id)

    artist = Artist.find_by(id: artist_id)
    return unless artist
  
    unless artist.image.attached?
      fetched_attachment = MusicBrainzAPI::FetchWikimedia.fetch_or_cache_artist_image(artist)
  
      if fetched_attachment
        artist.reload  # Reload fresh attachment info
  
        Rails.logger.info "FetchArtistImageJob: Successfully processed artist image for Artist MBID: #{artist.gid}."
  
        ActiveRecord::Base.connected_to(role: :writing) do
          ActiveRecord::Base.connection.schema_search_path = 'musicbrainz,public'
          
          Turbo::StreamsChannel.broadcast_replace_to(
            "artist_#{artist.gid}_image",
            target: "artist_image_#{artist.gid}",
            partial: 'search/artist_image_frame',
            locals: { artist: artist }
          )
        end
      else
        Rails.logger.warn "FetchArtistImageJob: Failed to fetch artist image for Artist MBID: #{artist.gid}."
      end
    end
  rescue StandardError => e
    Rails.logger.error "FetchArtistImageJob: Error processing Artist ID #{artist_id}: #{e.message}"
  end
  
end
