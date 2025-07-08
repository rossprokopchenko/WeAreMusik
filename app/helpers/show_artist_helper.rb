module ShowArtistHelper
  def release_status_options
    {
      "Official" => 1,
      "Promotion" => 2,
      "Bootleg" => 3,
      "Pseudo-Release" => 4,
      "Cancelled" => 6,
      "Expunged" => 38,
      "Withdrawn" => 5
    }
  end

  def release_group_type_options
    {
      "Album" => 1,
      "Single" => 2,
      "EP" => 3,
      "Broadcast" => 12,
      "Other" => 11
    }
  end

  def show_artist
    @artist = Artist.find_by(gid: params[:gid])
    @page_title = "#{@artist&.name || 'Unknown Artist'} - WeAreMusik"

    # Handle the case where the track is not found
    unless @artist
      flash[:alert] = "Artist not found."
      redirect_to search_path(search_type: @search_type, search_query: params[:search_query])
    end

    # Initialize @image. It might be nil if not attached yet.
    @image = @artist.image if @artist&.image&.attached?

    # If no cover art is attached, enqueue a background job to fetch it
    # We only enqueue if @release exists and has a GID, and no cover art is attached yet
    if @artist && @artist.gid.present? && !@image
      Rails.logger.info "Enqueuing FetchArtistImageJob for Artist MBID: #{@artist.gid}"
      FetchArtistImageJob.perform_later(@artist.id)
    end

    status_name = params[:release_status].presence || "Official"
    status_id = release_status_options[status_name] || release_status_options["Official"]

    type_name = params[:release_group_type].presence || "Album"
    type_id = release_group_type_options[type_name] || release_group_type_options["Album"]

    @releases = Release
      .includes(
        :release_countries,
        release_group: [
          :primary_type,
          { artist_credit: { artist_credit_names: :artist } }
        ]
      )
      .joins(
        :release_countries,
        release_group: [
          :primary_type,
          { artist_credit: { artist_credit_names: :artist } }
        ]
      )
      .where(
        is_canonical: true,
        artist_credit_names: { artist: @artist.id },
        release: { status: status_id }
      )
      .where(primary_type: { name: type_name })
      .order('release_country.date_year ASC, release_country.date_month ASC, release_country.date_day ASC')
      .distinct
      .references(:primary_type)

  end

  def save_artist
    @artist = Artist.find_by(gid: params[:gid])

    if current_user.saved_artists.exists?(@artist.id)
      flash.now[:notice] = "Already saved"
    else
      current_user.saved_artists.create!(artist_id: @artist.id)
      flash.now[:notice] = "Added to saved artists!"
    end

    respond_to do |format|
      format.turbo_stream { render "search/turbo/save_artist" }
      format.html { redirect_to search_show_artist_path(gid: @artist.gid), notice: "Added to saved artists!" }
    end
  end

  def remove_artist
    @artist = Artist.find_by(gid: params[:gid])
  
    saved_artist = current_user.saved_artists.find_by(artist_id: @artist.id)
  
    if saved_artist
      saved_artist.destroy!
      flash.now[:notice] = "Removed from saved artists."
    else
      flash.now[:notice] = "Artist not found in your saved artists."
    end
  
    respond_to do |format|
      format.turbo_stream { render "search/turbo/save_artist" }
      format.html { redirect_to search_show_artist_path(gid: @artist.gid), notice: "Removed from saved artists." }
    end
  end
  
end