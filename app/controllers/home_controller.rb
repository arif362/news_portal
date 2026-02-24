class HomeController < ApplicationController
  def index
    @breaking_news = Article.breaking_news.includes(:category, :author).limit(3)
    @featured_articles = Article.featured.includes(:category, :author).limit(4)
    @latest_articles = Article.recent.includes(:category, :author).limit(9)
    @categories = Category.active.roots.ordered
    @popular_articles = Article.popular.includes(:category).limit(5)
    @popular_tags = Tag.popular.limit(20)
  end
end
