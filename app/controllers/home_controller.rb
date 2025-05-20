class HomeController < ApplicationController
  include HomeHelper

  allow_unauthenticated_access

  before_action :load_data, only: [:index, :add_input_track, :clear_input_tracks]

  def index
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
      @total_tracks = Track.count
      @search = ransack_params
    
      # Search result tracks
      if params.dig(:q, :track_name_or_artists_or_album_name_cont).present?
        @search_result_tracks = ransack_result.page(1).per(50)
      else
        @search_result_tracks = Track.none
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
          puts "Recommended tracks: #{fetch_tracks_result}"
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

    def ransack_params
      Track.ransack(params[:q])
    end

    def ransack_result
      @search.result(distinct: true)
    end
end
