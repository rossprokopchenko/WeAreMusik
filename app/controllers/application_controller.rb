class ApplicationController < ActionController::Base
  include TracksHelper
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  before_action :set_current_page

  # def new
  #   FetchTracksJob.perform_later
  # end

  def set_current_page
    @current_page = controller_name
  end
end
