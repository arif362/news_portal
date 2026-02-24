class CategoriesController < ApplicationController
  def index
    @categories = Category.active.roots.ordered.includes(:children)
  end

  def show
    @category = Category.active.friendly.find(params[:slug])
    @pagy, @articles = pagy(
      @category.articles.recent.includes(:author, :tags),
      limit: 12
    )
    @subcategories = @category.children.active.ordered
  end
end
