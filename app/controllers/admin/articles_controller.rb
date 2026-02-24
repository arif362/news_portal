module Admin
  class ArticlesController < BaseController
    before_action :set_article, only: [ :show, :edit, :update, :destroy, :publish, :archive, :unpublish ]

    def index
      articles = Article.includes(:author, :category).order(created_at: :desc)
      articles = articles.where(status: params[:status]) if params[:status].present?
      @pagy, @articles = pagy(articles)
    end

    def new
      @article = Article.new
    end

    def create
      @article = current_user.articles.build(article_params)

      if @article.save
        redirect_to admin_article_path(@article), notice: "Article created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show; end

    def edit; end

    def update
      if @article.update(article_params)
        redirect_to admin_article_path(@article), notice: "Article updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @article.destroy
      redirect_to admin_articles_path, notice: "Article deleted."
    end

    def publish
      result = Articles::PublishService.call(article: @article, user: current_user)
      if result.success?
        redirect_to admin_article_path(@article), notice: "Article published."
      else
        redirect_to admin_article_path(@article), alert: result.errors.join(", ")
      end
    end

    def archive
      @article.update!(status: :archived)
      redirect_to admin_article_path(@article), notice: "Article archived."
    end

    def unpublish
      @article.update!(status: :draft)
      redirect_to admin_article_path(@article), notice: "Article moved to drafts."
    end

    private

    def set_article
      @article = Article.friendly.find(params[:id])
    end

    def article_params
      params.require(:article).permit(
        :title, :excerpt, :status, :category_id, :featured, :breaking,
        :comments_enabled, :meta_title, :meta_description, :meta_keywords,
        :body, :featured_image, tag_ids: []
      )
    end
  end
end
