class HomeController < ApplicationController
  # include HomeHelper

  allow_unauthenticated_access

  def index
    @total_tracks = Track.count

    @search = ransack_params

    @tracks = ransack_result.page(1).per(50)
    # @tracks = ransack_result.page(params[:page]).per(50)

    track_ids = session[:input_tracks] || []
    tracks = Track.where(track_id: track_ids).index_by(&:track_id)
    @input_tracks = track_ids.map { |id| tracks[id] }.compact
    
    # @input_tracks = Track.where(track_id: session[:input_tracks] || [])

  end

  def add_input_track
    track_id = params[:track_id]

    # puts "Adding input track #{track_id}"

    session[:input_tracks] ||= []

    unless session[:input_tracks].include?(track_id)
      session[:input_tracks] << track_id
      # puts "Added input track #{track_id} to array"
    end

    flash[:notice] = "Track added!"

    redirect_to root_path
  end

  def clear_input_tracks
    session.delete(:input_tracks)
    @total_tracks = Track.count

    flash[:notice] = "All tracks cleared!"

    redirect_to root_path
  end

  private 
    def ransack_params
      Track.ransack(params[:q])
    end

    def ransack_result
      @search.result(distinct:true)
    end
end