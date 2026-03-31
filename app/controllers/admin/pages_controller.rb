module Admin
  class PagesController < BaseController
    before_action :set_page, only: [ :edit, :update, :destroy ]

    def index
      @pages = Page.ordered.includes(:author)
    end

    def new
      @page = Page.new
    end

    def create
      @page = Page.new(page_params)
      @page.author = current_user
      if @page.save
        redirect_to admin_pages_path, notice: "Page created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @page.update(page_params)
        redirect_to admin_pages_path, notice: "Page updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @page.destroy
      redirect_to admin_pages_path, notice: "Page deleted."
    end

    private

    def set_page
      @page = Page.friendly.find(params[:id])
    end

    def page_params
      params.require(:page).permit(
        :title_en, :title_bn, :status, :show_in_navigation, :position,
        :meta_title_en, :meta_title_bn, :meta_description_en, :meta_description_bn,
        :body_en, :body_bn
      )
    end
  end
end
