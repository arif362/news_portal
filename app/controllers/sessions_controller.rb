class SessionsController < ApplicationController
  layout "auth"

  def new
    redirect_to root_path, notice: "Already signed in." if signed_in?
  end

  def create
    user = User.active.find_by("LOWER(email) = ?", params[:email]&.downcase&.strip)

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      user.track_sign_in!(ip: request.remote_ip)
      redirect_to_intended_or(root_path)
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: "Signed out successfully."
  end
end
