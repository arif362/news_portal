class PasswordResetsController < ApplicationController
  layout "auth"

  def new; end

  def create
    user = User.find_by("LOWER(email) = ?", params[:email]&.downcase&.strip)
    if user
      user.generate_password_reset_token!
      PasswordResetMailer.reset_email(user).deliver_later
    end
    redirect_to login_path, notice: "If the email exists, reset instructions have been sent."
  end

  def edit
    @user = User.find_by!(password_reset_token: params[:token])
    redirect_to login_path, alert: "Token expired." unless @user.password_reset_token_valid?
  end

  def update
    @user = User.find_by!(password_reset_token: params[:token])

    if @user.password_reset_token_valid? && @user.update(password_params)
      @user.clear_password_reset_token!
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Password updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
