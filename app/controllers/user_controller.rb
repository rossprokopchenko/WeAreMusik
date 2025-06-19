class UserController < ApplicationController
  include UserHelper

  before_action :set_user, only: %i[ index show edit update ]

  def index

  end

  def show
    @user = User.find_by!(gid: params[:gid])
    @page_title = "#{@user.username}'s Profile - WeAreMusik"

    @favorite_releases = @user.releases.includes(:artist_credit).limit(10)
  end

  def edit
    @page_title = "Edit Profile - WeAreMusik"
  end

  def update
    puts "Updating user with params: #{user_params.inspect}"

    if @user.update(user_params)
      redirect_to user_path(@user), notice: 'User profile was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to home_path
  end


  private
    def set_user
      # IMPORTANT: Change from find(params[:id]) to find_by!(gid: params[:gid])
      puts "Parameters received: #{params.inspect}"
      @user = User.find_by!(gid: params[:gid])
    rescue ActiveRecord::RecordNotFound
      # Handle case where user with that GID is not found
      puts "Profile not found"
      flash[:alert] = "User profile not found."
      redirect_to user_path(cookies[:user_gid]) # Or wherever you want to redirect
    end

    def user_params
      params.expect(user: [ :user_id, :gid, :username, :biography, :profile_picture, user_social_links_attributes: [:id, :platform, :url, :_destroy] ])
    end



end