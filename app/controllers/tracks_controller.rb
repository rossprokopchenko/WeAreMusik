# app/controllers/tracks_controller.rb
class TracksController < ApplicationController
  def index
    if params[:q].present?
      # Build the base scope for the search, including necessary eager loads for the count
      # base_scope = Track
      #   .multiple_column_search(params[:q])
      #   .with_pg_search_rank
      #   .joins(medium: :format)
      #   .where("medium_format.name = ? OR medium_format.id = ?", "Digital Media", 12)
      #   .distinct
      #   .includes(:recording, artist_credit: :artists)

      meilisearch_index = Meilisearch::Rails.client.index('Track')
      requested_page_number = params[:page].to_i
      meilisearch_query_page = (requested_page_number > 0) ? requested_page_number : 1

      meilisearch_results = meilisearch_index.search(params[:q], {
        filter: ["medium_format_id = 12"],
        page: meilisearch_query_page,
        hits_per_page: 50
      })

      # Manually get the total count *before* applying pagination or specific selects
      # total_results = base_scope.count
      # total_results = meilisearch_results.total_hits
      track_ids = meilisearch_results['hits'].map { |hit| hit['id'] }

      # Apply pagination and column selection to the base scope
      # @tracks = base_scope
      #   .paginate(page: params[:page], per_page: 50)
      #   .select(:id, :name, :recording, :artist_credit)

      tracks_to_paginate = Track.where(id: track_ids)
        .includes(:recording, artist_credit: :artists)
        .in_order_of(:id, track_ids)

      per_page     = meilisearch_results['hitsPerPage'].to_i
      total_count  = meilisearch_results['totalHits'].to_i
      current_page = meilisearch_results['page'].to_i

      kaminari_offset_value = (current_page - 1) * per_page
      kaminari_offset_value = [kaminari_offset_value, 0].max 

      # Use Kaminari to paginate the results - convert the tracks_to_paginate to a Kaminari::PaginatableArray
      # Use @tracks.current_page to get current page number and @tracks.total_count for total hits
      @tracks = Kaminari::PaginatableArray.new(
        tracks_to_paginate.to_a, # This is already the content for the current page
        limit: per_page,         # The number of items per page (your hits_per_page)
        offset: kaminari_offset_value,    # The calculated offset from Meilisearch's 0-based page
        total_count: total_count # The total number of hits from Meilisearch
      )

    else
      @tracks = Track.none.page(0).per(50)
    end

    respond_to do |format|
      format.html do
        # For a full page load, render the standard index view
      end
      format.turbo_stream do
        # This will replace the content inside the "search_result_tracks" turbo_frame_tag
        render turbo_stream: turbo_stream.update("search_result_tracks", partial: "tracks/search_result_tracks", locals: { tracks: @tracks })
      end
    end
  end

  def show
    @track = Track.includes(
        :recording, 
        artist_credit: :artists, 
        medium: :release,
      ).find_by(id: params[:id])

    # Handle the case where the track is not found
    unless @track
      flash[:alert] = "Track not found."
      redirect_to tracks_path
    end
  end
end