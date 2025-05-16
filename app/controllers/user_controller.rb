class UserController < ApplicationController
  before_action :set_user, only: %i[ index show edit update ]

  def index
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user
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
      @user = User.find(cookies[:user_id])
    end

    def user_params
      params.expect(user: [ :user_id, :username, :biography, :profile_picture ])
    end

end