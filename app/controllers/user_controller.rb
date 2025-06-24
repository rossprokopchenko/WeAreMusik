class UserController < ApplicationController
  allow_unauthenticated_access only: [:new, :create, :verify, :confirm_verification]
  before_action :redirect_if_authenticated, only: [:new, :create, :verify, :confirm_verification]

  before_action :set_user, only: %i[ index show edit update follow unfollow destroy ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
  
    if @user.save
      UserMailer.verification_email(@user).deliver_later
      redirect_to verify_path(email: @user.email_address), notice: "Check your email for a verification code."
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def verify
    @user = User.find_by(email_address: params[:email]) || Current.user

    @code = params[:code]
    @page_title = "Verify Account - WeAreMusik"
  end
  
  def confirm_verification
    @user = User.find_by(email_address: params[:email])
    
    if @user&.verification_code == params[:code]
      @user.update(verified: true)
      redirect_to login_path, notice: "Your email has been verified. You can now log in."
    else
      flash.now[:alert] = "Invalid verification code."
      render :verify, status: :unprocessable_entity
    end
  end

  def index

  end

  def show
    @user = User.find_by!(gid: params[:gid])
    @page_title = "#{@user.username}'s Profile - WeAreMusik"

    @favorite_releases = @user.releases.includes(:artist_credit)
    @favorite_artists = @user.artists
    
    @expanded = false
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

  def follow
    puts "Current user: #{current_user.inspect}"

    current_user.following << @user unless current_user.following.include?(@user)

    respond_to do |format|
      format.html { redirect_to @user, notice: 'Followed successfully.' }
      format.turbo_stream
    end
  end

  def unfollow
    current_user.following.destroy(@user)

    respond_to do |format|
      format.html { redirect_to @user, notice: 'Unfollowed successfully.' }
      format.turbo_stream
    end
  end

  private
    def set_user
      @user = User.find_by!(gid: params[:gid])
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "User profile not found."
      redirect_to user_path(cookies[:user_gid])
    end

    def user_params
      params.require(:user).permit(
        :user_id,
        :gid,
        :username,
        :email_address,
        :password,
        :password_confirmation,
        :biography,
        :profile_picture,
        user_social_links_attributes: [:id, :platform, :url, :_destroy]
      )
    end

    def redirect_if_authenticated
      puts "Redirecting because already authenticated"
      redirect_to root_path, notice: "You're already logged in." if authenticated?
    end

end