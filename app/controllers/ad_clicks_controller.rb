class AdClicksController < ApplicationController
  def show
    ad = Advertisement.friendly.find(params[:id])
    ad.increment_clicks!
    redirect_to ad.target_url.presence || root_url, allow_other_host: true
  end
end
