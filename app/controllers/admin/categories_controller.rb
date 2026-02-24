module Admin
  class CategoriesController < BaseController
    before_action :set_category, only: [ :edit, :update, :destroy ]

    def index
      @categories = Category.roots.ordered.includes(:children)
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
      params.require(:category).permit(:name, :description, :parent_id, :position, :active, :meta_title, :meta_description)
    end
  end
end
