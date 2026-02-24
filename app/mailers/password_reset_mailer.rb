class PasswordResetMailer < ApplicationMailer
  def reset_email(user)
    @user = user
    @reset_url = edit_password_reset_url(token: user.password_reset_token)
    mail(to: @user.email, subject: "Reset Your Password - News Portal")
  end
end
