class ApplicationController < ActionController::Base
  include TracksHelper
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper_method :current_user
  before_action :set_current_page, :set_default_title

  # def new
  #   FetchTracksJob.perform_later
  # end

  def set_current_page
    @current_page = controller_name
  end

  private

  def current_user
    @current_user ||= User.find_by(gid: cookies.signed[:user_gid])
  end

  def set_default_title
    @page_title = "WeAreMusik"
  end
end
