class TracksController < ApplicationController
  include TracksHelper

  def index
    @total_tracks = Track.count

    @search = ransack_params
    @tracks = ransack_result
  end

  def show
    @track = Track.find_by(track_id: params[:id])
  end

  # def new
  #   @product = Track.new
  # end

  private 
    def ransack_params
      Track.ransack(params[:q])
    end

    def ransack_result
      @search.result(distinct:true)
    end

end
