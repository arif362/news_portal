module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :signed_in?
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def signed_in?
    current_user.present?
  end

  def authenticate_user!
    unless signed_in?
      store_intended_url
      redirect_to login_path, alert: "Please sign in to continue."
    end
  end

  def require_admin!
    authenticate_user!
    return if performed?

    redirect_to root_path, alert: "Access denied." unless current_user&.admin?
  end

  def require_staff!
    authenticate_user!
    return if performed?

    redirect_to root_path, alert: "Access denied." unless current_user&.staff?
  end

  def store_intended_url
    session[:intended_url] = request.original_url if request.get? || request.head?
  end

  def redirect_to_intended_or(default)
    url = session.delete(:intended_url)
    redirect_to(url || default)
  end
end
