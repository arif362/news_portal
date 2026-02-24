module Admin
  class BaseController < ApplicationController
    before_action :require_staff!
    layout "admin"
  end
end
