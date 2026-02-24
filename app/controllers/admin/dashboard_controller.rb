module Admin
  class DashboardController < BaseController
    def index
      @total_articles = Article.count
      @published_articles = Article.published.count
      @draft_articles = Article.drafts.count
      @total_comments = Comment.count
      @pending_comments = Comment.pending_review.count
      @total_users = User.count
      @recent_articles = Article.order(created_at: :desc).includes(:author, :category).limit(5)
      @recent_comments = Comment.pending_review.includes(:user, :article).order(created_at: :desc).limit(10)
    end
  end
end
