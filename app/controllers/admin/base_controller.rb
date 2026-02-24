module Admin
  class BaseController < ApplicationController
    before_action :require_staff!
    layout "admin"

    private

    # Admin is English-only — never pass locale in admin URLs
    def default_url_options
      {}
    end
  end
end
