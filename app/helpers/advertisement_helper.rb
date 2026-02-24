module AdvertisementHelper
  def render_ad(placement, limit: 1)
    ads = Advertisement.for_placement(placement).limit(limit)
    return if ads.empty?

    ads.each(&:increment_impressions!)
    render partial: "advertisements/#{placement}", collection: ads, as: :ad
  end
end
