
class FetchCoverArtJob < ApplicationJob

  def perform(release_id)
    release = Release.find_by(id: release_id)
    return unless release

    unless release.cover_art.attached?
      fetched_attachment = MusicBrainzAPI::FetchCaa.fetch_or_cache_cover_art(release)

      if fetched_attachment
        Rails.logger.info "FetchCoverArtJob: Successfully processed cover art for Release MBID: #{release.gid}."

        # Broadcast the updated turbo_frame for this release's cover art
        # This will replace the content inside the turbo_frame_tag with ID "release_cover_art_#{release.id}"
        Turbo::StreamsChannel.broadcast_replace_to(
          "release_#{release.gid}_cover_art", # The stream name to broadcast to
          target: "release_cover_art_#{release.gid}", # The ID of the turbo_frame_tag to update
          partial: 'search/cover_art_frame',
          locals: { release: release }
        )
      else
        Rails.logger.warn "FetchCoverArtJob: Failed to fetch cover art for Release MBID: #{release.gid}."
      end
    end
  rescue StandardError => e
    Rails.logger.error "FetchCoverArtJob: Error processing for Release ID #{release_id}: #{e.message}"
  end
  
end