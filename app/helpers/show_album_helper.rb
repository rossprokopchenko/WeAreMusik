module ShowAlbumHelper

  def show_album
    @release = Release.find_by(gid: params[:gid])
    @page_title = "#{@release&.name || 'Unknown Album'} - WeAreMusik"

    # Handle the case where the track is not found
    unless @release
      flash[:alert] = "Album not found."
      redirect_to search_path(search_type: @search_type, search_query: params[:search_query])
    end

    # Initialize @cover_art. It might be nil if not attached yet.
    @cover_art = @release.cover_art if @release&.cover_art&.attached?

    # If no cover art is attached, enqueue a background job to fetch it
    # We only enqueue if @release exists and has a GID, and no cover art is attached yet
    if @release && @release.gid.present? && !@cover_art
      Rails.logger.info "Enqueuing FetchCoverArtJob for Release MBID: #{@release.gid}"
      FetchCoverArtJob.perform_later(@release.id) # Enqueue the job with the release's ID
    end

    @tracks = Track.includes(:recording, :artist_credit)
      .joins(:medium)
      .where('medium.release = ?', @release.id)
      .order('medium.position ASC, track.position ASC')

    @external_urls = @release.release_group.external_urls.select do |url|
      URI.parse(url.url).host.end_with?('.com')
    end
    
  end

  def save_release
    release = Release.find(params[:gid])

    if current_user.saved_releases.exists?(release.id)
      flash.now[:notice] = "Already saved"
    else
      current_user.saved_releases.create!(release_id: release.id)
      flash.now[:notice] = "Added to saved albums!"
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to search_show_album_path(gid: release.gid), notice: "Added to saved" }
    end
  end
end