class FetchCoverArtJob < ApplicationJob
  queue_as :default

  def perform(release_id)
    
    ActiveRecord::Base.connected_to(role: :writing) do
      ActiveRecord::Base.connection.schema_search_path = 'musicbrainz,public'
      ActiveStorage::Attachment.table_name = 'public.active_storage_attachments'
      ActiveStorage::Blob.table_name = 'public.active_storage_blobs'

      Rails.logger.info ">>> SCHEMA_SEARCH_PATH: #{ActiveRecord::Base.connection.schema_search_path}"
      Rails.logger.info ">>> INDEXES FOR active_storage_attachments:"
      indexes = ActiveRecord::Base.connection.indexes('active_storage_attachments')
      indexes.each do |idx|
        Rails.logger.debug "Index: #{idx.name} | Unique: #{idx.unique} | Columns: #{idx.columns.inspect}"
      end
      
      release = Release.find_by(id: release_id)

      unless release
        Rails.logger.warn "FetchCoverArtJob: No Release found with ID #{release_id}."
        return
      end

      # Defensive: ensure the release has a valid, unique GID
      unless release.gid.present?
        Rails.logger.error "FetchCoverArtJob: Release ID #{release.id} has no GID — cannot proceed."
        return
      end

      if release.cover_art.attached? && release.cover_art.persisted?
        Rails.logger.info "FetchCoverArtJob: Cover art already attached for MBID: #{release.gid}."
        return
      end

      # Attempt to fetch or cache cover art
      fetched_attachment = MusicBrainzAPI::FetchCaa.fetch_or_cache_cover_art(release)

      if fetched_attachment.present?
        release.reload # Ensure attachment is persisted before broadcasting

        Rails.logger.info "FetchCoverArtJob: Successfully processed cover art for Release MBID: #{release.gid}."

        Rails.logger.debug "SCHEMA SEARCH PATH: #{ActiveRecord::Base.connection.schema_search_path}"
        Rails.logger.debug "VISIBLE INDEXES: #{ActiveRecord::Base.connection.indexes('active_storage_attachments').map(&:name)}"

        Turbo::StreamsChannel.broadcast_replace_to(
          "release_#{release.gid}_cover_art",
          target: "release_cover_art_#{release.gid}",
          partial: 'search/cover_art_frame',
          locals: { release: release }
        )
      else
        Rails.logger.warn "FetchCoverArtJob: Failed to fetch cover art for MBID: #{release.gid}."
      end
    
    end
  rescue => e
    Rails.logger.error "FetchCoverArtJob: Error processing Release ID #{release_id} — #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}"
  end
end
