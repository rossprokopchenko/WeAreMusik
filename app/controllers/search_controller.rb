class SearchController < ApplicationController
  include ShowTrackHelper
  include ShowAlbumHelper
  include ShowArtistHelper
  include Authentication

  allow_unauthenticated_access

  before_action :set_search_type, only: [:index]
  before_action :set_page_title

  def index
    per_page = 50

    # Determine the model based on search_by parameter
    puts "Search type: #{@search_type}"

    model_to_search = case @search_type
      when 'albums'
        Release
      when 'artists'
        Artist
      when 'users'
        User
      else # Default to track
        Track
    end

    if params[:search_query].present?
      meilisearch_index = Meilisearch::Rails.client.index(model_to_search.name)
      requested_page_number = params[:page].to_i
      meilisearch_query_page = (requested_page_number > 0) ? requested_page_number : 1

      search_options = {
        page: meilisearch_query_page,
        hits_per_page: per_page
      }

      # Filter types based on the model being searched
      if model_to_search == Track

        search_options[:filter] = 'is_canonical = true'

      elsif model_to_search == Release
        search_options[:filter] = 'is_canonical = true'

      elsif model_to_search == Artist

      elsif model_to_search == User

      end
      
      meilisearch_results = meilisearch_index.search(params[:search_query], search_options)

      puts "Meilisearch results: #{meilisearch_results.inspect}"
      puts "Meilisearch totalHits: #{meilisearch_results['totalHits']}"
      puts "Meilisearch hits (first 3 IDs): #{meilisearch_results['hits'].map { |h| h['id'] }.take(3).join(', ')}" if meilisearch_results['hits'].any?

      ids_to_fetch = meilisearch_results['hits'].map { |hit| hit['id'] }
      puts "IDs to fetch from DB: #{ids_to_fetch.inspect}"

      # Fetch records from the database using the IDs from Meilisearch
      case @search_type
        when 'albums'
          @results = Release.where(id: ids_to_fetch)
                          .includes(:artist_credit)
                          .in_order_of(:id, ids_to_fetch)
        when 'artists'
          @results = Artist.where(id: ids_to_fetch)
                          .in_order_of(:id, ids_to_fetch)
        when 'users'
          @results = User.where(id: ids_to_fetch)
                        .in_order_of(:id, ids_to_fetch)
        when 'tracks'
          @results = Track.where(id: ids_to_fetch)
                          .includes(:recording, artist_credit: :artists)
                          .in_order_of(:id, ids_to_fetch)
        else # Default to artists
          @results = Artist.where(id: ids_to_fetch)
                          .in_order_of(:id, ids_to_fetch)
      end

      # per_page     = meilisearch_results['hitsPerPage'].to_i
      total_count  = meilisearch_results['totalHits'].to_i
      current_page = meilisearch_results['page'].to_i

      kaminari_offset_value = (current_page - 1) * per_page
      kaminari_offset_value = [kaminari_offset_value, 0].max 

      # Use Kaminari to paginate the results - convert the tracks_to_paginate to a Kaminari::PaginatableArray
      # Use @tracks.current_page to get current page number and @tracks.total_count for total hits
      @paginated_results = Kaminari::PaginatableArray.new(
        @results, # This is already the content for the current page
        limit: per_page,         # The number of items per page (your hits_per_page)
        offset: kaminari_offset_value,    # The calculated offset from Meilisearch's 0-based page
        total_count: total_count # The total number of hits from Meilisearch
      )

    else
      case @search_type
        when 'users'
          @paginated_results = User.page(params[:page]).per(per_page)

        else
          @paginated_results = Kaminari::PaginatableArray.new([], limit: 50, offset: 0, total_count: 0)
      end
    end

    # puts "Rendering format: #{request.format}"

    respond_to do |format|
      format.html do
        # For a full page load, render the standard index view
        puts "Rendering HTML for search results"
      end
      format.turbo_stream do
        puts "Rendering turbo stream for search results"
        render turbo_stream: turbo_stream.update("search_result_table", partial: "search/search_result_#{@search_type.pluralize}", locals: { results: @paginated_results })
      end
    end
  end

  private 
    def set_search_type
      puts "Setting search_type mode from params: #{params[:search_type]}"
      @search_type = params[:search_type].presence || 'tracks'  # Use plural to match <option> values
    end

    def set_page_title
      @page_title = "Search - WeAreMusik"
    end
end
