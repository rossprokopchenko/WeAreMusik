class HomeController < ApplicationController
  include HomeHelper

  allow_unauthenticated_access

  before_action :load_data, only: [:index, :add_input_track, :clear_input_tracks]

  def index
    @page_title = "Home - WeAreMusik"

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def add_input_track
    track_id = params[:track_id]
    session[:input_tracks] ||= []

    unless session[:input_tracks].include?(track_id)
      session[:input_tracks] << track_id
    end

    load_data

    flash.now[:notice] = "Track added"

    respond_to do |format|
      format.html { redirect_to root_path, notice: flash.now[:notice] }
      format.turbo_stream
    end
  end

  def clear_input_tracks
    session.delete(:input_tracks)
    
    load_data

    flash.now[:notice] = "All tracks cleared"

    respond_to do |format|
      format.html { redirect_to root_path, notice: flash.now[:notice] }
      format.turbo_stream
    end
  end

  private

    def load_data
      # @total_tracks = Track.count
      
      # if params[:q].present?
      #   @search_result_tracks = Track
      #     .multiple_column_search(params[:q])
      #     .select(:id, :name, :medium, :recording, :artist_credit)
      #     .includes(:recording, :medium, artist_credit: :artists)
      #     .page(params[:page])         # <-- pagination here
      #     .per(50)                     # <-- 50 results per page
      # else
      #   @search_result_tracks = Track.none
      # end

      if params[:q].present?
        # Build the base scope for the search, including necessary eager loads for the count
        base_scope = Track
          .multiple_column_search(params[:q])
          .includes(:recording, artist_credit: :artists)
  
        # Manually get the total count *before* applying pagination or specific selects
        total_tracks = base_scope.count
  
        # Apply pagination and column selection to the base scope
        @search_result_tracks = base_scope
          .page(params[:page])
          .per(50)
          .select(:id, :name, :recording, :artist_credit, :medium)
  
        # Manually set the total_count instance variable for Kaminari
        @search_result_tracks.instance_variable_set(:@_total_count, total_tracks)
  
      else
        @search_result_tracks = Track.none.page(params[:page])
      end

      # Input tracks from session
      track_ids = session[:input_tracks] || []
      input_tracks_hash = Track.where(track_id: track_ids).index_by(&:track_id)
      @input_tracks = track_ids.map { |id| input_tracks_hash[id] }.compact

      # Recommended tracks from API — convert to Track model instances
      if @input_tracks.any?
        fetch_tracks = WeAreMusikAPI::Services::FetchTracks.new
        fetch_tracks_result = fetch_tracks.get_recommended_tracks(input_tracks: track_ids)

        if fetch_tracks_result[:success]
          recommended_ids = fetch_tracks_result[:data] || []
          recommended_tracks_hash = Track.where(track_id: recommended_ids).index_by(&:track_id)
          @recommended_tracks = recommended_ids.map { |id| recommended_tracks_hash[id] }.compact
        else
          @recommended_tracks = Track.none
        end
      else
        @recommended_tracks = Track.none
      end
    end
end
