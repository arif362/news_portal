class RegistrationsController < ApplicationController
  layout "auth"

  def new
    redirect_to root_path if signed_in?
    @user = User.new
  end

  def create
    @user = User.new(registration_params)
    @user.role = :reader

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Welcome to News Portal!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:email, :username, :first_name, :last_name, :password, :password_confirmation)
  end
end
