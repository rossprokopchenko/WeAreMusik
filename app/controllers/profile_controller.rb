class ProfileController < ApplicationController

  def index
    @user = User.find(cookies[:user_id])

    # @current_user ||= User.find_by(id: session[:current_user_id]) if session[:current_user_id]

    puts "Current User: #{@user}"

    @title = "hello"
  end

end