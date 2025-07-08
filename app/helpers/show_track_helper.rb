module ShowTrackHelper

  def show_track
    @track = Track.find_by(gid: params[:gid])
    @page_title = "#{@track&.name || 'Unknown Track'} - WeAreMusik"

    # Handle the case where the track is not found
    unless @track
      flash[:alert] = "Track not found."
      redirect_to search_path(search_type: @search_type, search_query: params[:search_query])
    end

    @release = @track.release

    # Initialize @cover_art. It might be nil if not attached yet.
    @cover_art = @release.cover_art if @release&.cover_art&.attached?

    # If no cover art is attached, enqueue a background job to fetch it
    # We only enqueue if @release exists and has a GID, and no cover art is attached yet
    if @release && @release.gid.present? && !@cover_art
      Rails.logger.info "Enqueuing FetchCoverArtJob for Release MBID: #{@release.gid}"
      FetchCoverArtJob.perform_later(@release.id) # Enqueue the job with the release's ID
    end

    @external_urls = @track.recording.external_urls.select do |url|
      URI.parse(url.url).host.end_with?('.com')
    end
    
  end

  def like_track
    @track = Track.find_by!(gid: params[:gid])
  
    if current_user.liked_tracks.exists?(@track.id)
      flash.now[:notice] = "Already saved"
    else
      current_user.liked_tracks.create!(track_id: @track.id)
      flash.now[:notice] = "Added to liked tracks!"
    end
  
    respond_to do |format|
      format.turbo_stream { render "search/turbo/like_track" }
      format.html { redirect_to search_show_track_path(gid: @track.gid), notice: "Liked track" }
    end
  end
  

  def unlike_track
    @track = Track.find_by(gid: params[:gid])
  
    liked_track = current_user.liked_tracks.find_by(track_id: @track.id)
  
    if liked_track
      liked_track.destroy!
      flash.now[:notice] = "Removed from liked tracks."
    else
      flash.now[:notice] = "Track not found in your liked tracks."
    end
  
    respond_to do |format|
      format.turbo_stream { render "search/turbo/like_track" }
      format.html { redirect_to search_show_track_path(gid: @track.gid), notice: "Removed from liked tracks." }
    end
  end
  
  
end