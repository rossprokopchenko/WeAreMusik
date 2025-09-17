class FetchArtistRecommendationsJob < ApplicationJob
  queue_as :default

  def perform(artist_id, limit: 10)
    artist = Artist.find_by(id: artist_id)

    unless artist
      Rails.logger.warn "FetchArtistRecommendationsJob: No Artist found with ID #{artist_id}."
      return
    end

    unless artist.gid.present?
      Rails.logger.warn "FetchArtistRecommendationsJob: Artist has no MBID, cannot fetch recommendations."
      return
    end

    Rails.logger.info "FetchArtistRecommendationsJob: Fetching recommendations for Artist MBID: #{artist.gid}"

    begin
      # Fetch recommended artist MBIDs
      recommended_mbids = WeAreMusikAPI::FetchRecommendations.fetch_similar_artists(
        artist.gid,
        limit: limit
      )

      if recommended_mbids.present?
        Rails.logger.info "FetchArtistRecommendationsJob: Fetched #{recommended_mbids.size} recommendations for Artist MBID: #{artist.gid}"

        # Broadcast via Turbo Streams for real-time updates
        Turbo::StreamsChannel.broadcast_replace_to(
          "artist_#{artist.gid}_recommendations",
          target: "artist_recommendations_#{artist.gid}",
          partial: 'artists/recommendations',
          locals: { artist: artist, recommendations: recommended_mbids }
        )
      else
        Rails.logger.warn "FetchArtistRecommendationsJob: No recommendations returned for Artist MBID: #{artist.gid}"
      end

    rescue => e
      Rails.logger.error "FetchArtistRecommendationsJob: Error fetching recommendations for Artist ID #{artist_id} — #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}"
    end
  end
end
