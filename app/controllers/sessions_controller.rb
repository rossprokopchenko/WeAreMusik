class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }
  
  before_action :redirect_if_authenticated, only: [:new]
  before_action :set_page_title

  def new
  end

  def create
    if user = User.authenticate_by(username: params[:username], password: params[:password])

      if user.verified?
        start_new_session_for user
        redirect_to after_authentication_url, notice: "Welcome, #{user.username}!"
      else
        redirect_to verify_path(email: @user.email_address), alert: "Please verify your account first."
      end
    else
      redirect_to login_path, alert: "Try another username or password."
    end
  end
  

  def destroy
    terminate_session
    session[:return_to_after_authenticating] = request.referer if request.referer.present?
    redirect_to login_path
  end
  

  private

    def redirect_if_authenticated
      redirect_to root_path, notice: "You're already logged in." if authenticated?
    end

    def set_page_title
      @page_title = "Login - WeAreMusik"
    end
end
