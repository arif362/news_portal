module Admin
  class AdvertisementsController < BaseController
    before_action :set_advertisement, only: [ :show, :edit, :update, :destroy, :activate, :pause ]

    def index
      ads = Advertisement.ordered
      ads = ads.where(status: params[:status]) if params[:status].present?
      ads = ads.where(placement: params[:placement]) if params[:placement].present?
      if params[:q].present?
        ads = ads.where("title->>'en' ILIKE :q", q: "%#{params[:q]}%")
      end
      @pagy, @advertisements = pagy(ads)
    end

    def show; end

    def new
      @advertisement = Advertisement.new
    end

    def create
      @advertisement = Advertisement.new(advertisement_params)

      if @advertisement.save
        redirect_to admin_advertisement_path(@advertisement), notice: "Advertisement created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @advertisement.update(advertisement_params)
        redirect_to admin_advertisement_path(@advertisement), notice: "Advertisement updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @advertisement.destroy
      redirect_to admin_advertisements_path, notice: "Advertisement deleted."
    end

    def activate
      @advertisement.update!(status: :active)
      redirect_to admin_advertisement_path(@advertisement), notice: "Advertisement activated."
    end

    def pause
      @advertisement.update!(status: :paused)
      redirect_to admin_advertisement_path(@advertisement), notice: "Advertisement paused."
    end

    private

    def set_advertisement
      @advertisement = Advertisement.friendly.find(params[:id])
    end

    def advertisement_params
      params.require(:advertisement).permit(
        :title_en, :title_bn, :description_en, :description_bn,
        :ad_type, :embed_code, :target_url, :open_in_new_tab,
        :placement, :position, :status, :starts_at, :ends_at,
        :responsive, :alt_text, :image
      )
    end
  end
end
