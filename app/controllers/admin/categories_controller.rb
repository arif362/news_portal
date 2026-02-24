module Admin
  class CategoriesController < BaseController
    before_action :set_category, only: [ :edit, :update, :destroy ]

    def index
      if params[:q].present?
        q = "%#{params[:q]}%"
        @categories = Category.where("name->>'en' ILIKE :q OR name->>'bn' ILIKE :q", q: q).ordered
        @searching = true
      else
        @categories = Category.roots.ordered.includes(:children)
      end
    end

    def new
      @category = Category.new
    end

    def create
      @category = Category.new(category_params)
      if @category.save
        redirect_to admin_categories_path, notice: "Category created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @category.update(category_params)
        redirect_to admin_categories_path, notice: "Category updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @category.articles.any?
        redirect_to admin_categories_path, alert: "Cannot delete category with articles."
      else
        @category.destroy
        redirect_to admin_categories_path, notice: "Category deleted."
      end
    end

    private

    def set_category
      @category = Category.friendly.find(params[:id])
    end

    def category_params
      params.require(:category).permit(
        :name_en, :name_bn, :description_en, :description_bn,
        :parent_id, :position, :active,
        :meta_title_en, :meta_title_bn, :meta_description_en, :meta_description_bn
      )
    end
  end
end
