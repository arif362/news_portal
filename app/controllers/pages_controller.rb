class PagesController < ApplicationController
  def show
    @page = Page.published.friendly.find(params[:slug])
  end
end
