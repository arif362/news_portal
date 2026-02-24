class SearchController < ApplicationController
  def index
    if params[:q].present?
      articles = Articles::SearchService.call(query: params[:q])
      @pagy, @articles = pagy(articles, limit: 12)
      @query = params[:q]
    else
      @articles = Article.none
      @query = ""
    end
  end
end
