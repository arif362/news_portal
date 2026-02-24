class TagsController < ApplicationController
  def show
    @tag = Tag.friendly.find(params[:slug])
    @pagy, @articles = pagy(
      Article.recent.by_tag(@tag.id).includes(:category, :author),
      limit: 12
    )
  end
end
