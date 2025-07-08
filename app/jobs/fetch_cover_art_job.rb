class FetchCoverArtJob < ApplicationJob
  queue_as :default

  def perform(release_id)
    Rails.logger.info ">>> SCHEMA_SEARCH_PATH: #{ActiveRecord::Base.connection.schema_search_path}"
    Rails.logger.info ">>> ActiveStorage::Attachment.table_name: #{ActiveStorage::Attachment.table_name}"

    ActiveRecord::Base.connection.indexes('active_storage_attachments').each do |idx|
      Rails.logger.info "Index: #{idx.name} | Unique: #{idx.unique} | Columns: #{idx.columns.inspect}"
    end

    release = Release.find_by(id: release_id)

    unless release
      Rails.logger.warn "FetchCoverArtJob: No Release found with ID #{release_id}."
      return
    end

    if release.cover_art.attached? && release.cover_art.persisted?
      Rails.logger.info "FetchCoverArtJob: Cover art already attached for MBID: #{release.gid}."
      return
    end

    fetched_attachment = MusicBrainzAPI::FetchCaa.fetch_or_cache_cover_art(release)

    if fetched_attachment.present?
      release.reload

      Rails.logger.info "FetchCoverArtJob: Successfully processed cover art for Release MBID: #{release.gid}."

      Turbo::StreamsChannel.broadcast_replace_to(
        "release_#{release.gid}_cover_art",
        target: "release_cover_art_#{release.gid}",
        partial: 'search/elements/cover_art_frame',
        locals: { release: release }
      )
    else
      Rails.logger.warn "FetchCoverArtJob: Failed to fetch cover art for MBID: #{release.gid}."
    end

  rescue => e
    Rails.logger.error "FetchCoverArtJob: Error processing Release ID #{release_id} — #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}"
  end
end
