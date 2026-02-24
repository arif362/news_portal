class ArticlesController < ApplicationController
  def index
    articles = Article.recent.includes(:category, :author, :tags)
    articles = articles.by_category(params[:category_id]) if params[:category_id].present?
    @pagy, @articles = pagy(articles, limit: 12)
  end

  def show
    @article = Article.published.friendly.find(params[:slug])
    @article.increment_views!
    @related_articles = Article.published
                              .where(category_id: @article.category_id)
                              .where.not(id: @article.id)
                              .includes(:author)
                              .limit(4)
    @comments = @article.comments.approved.top_level
                        .includes(:user, replies: :user)
                        .order(created_at: :desc)
    @comment = Comment.new if signed_in?
  end
end
