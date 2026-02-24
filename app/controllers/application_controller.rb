class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Authentication
  include Authentication

  # Pagination support
  include Pagy::Method

  # Global error handling
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  rescue_from ActionController::ParameterMissing, with: :bad_request

  private

  def not_found
    respond_to do |format|
      format.html { render file: Rails.public_path.join("404.html"), status: :not_found, layout: false }
      format.json { render json: { error: "Not found" }, status: :not_found }
    end
  end

  def unprocessable_entity(exception)
    respond_to do |format|
      format.html { render file: Rails.public_path.join("422.html"), status: :unprocessable_entity, layout: false }
      format.json { render json: { error: exception.message }, status: :unprocessable_entity }
    end
  end

  def bad_request(exception)
    respond_to do |format|
      format.html { render file: Rails.public_path.join("400.html"), status: :bad_request, layout: false }
      format.json { render json: { error: exception.message }, status: :bad_request }
    end
  end
end
