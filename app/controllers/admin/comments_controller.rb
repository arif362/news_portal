module Admin
  class CommentsController < BaseController
    before_action :set_comment, only: [ :show, :destroy, :approve, :reject ]

    def index
      comments = Comment.includes(:user, :article).order(created_at: :desc)
      comments = comments.where(status: params[:status]) if params[:status].present?
      if params[:q].present?
        q = "%#{params[:q]}%"
        comments = comments.joins(:user, :article)
          .where("comments.body ILIKE :q OR users.first_name ILIKE :q OR users.last_name ILIKE :q OR articles.title->>'en' ILIKE :q", q: q)
      end
      @pagy, @comments = pagy(comments)
    end

    def show; end

    def destroy
      @comment.destroy
      redirect_to admin_comments_path, notice: "Comment deleted."
    end

    def approve
      @comment.update!(status: :approved)
      redirect_to admin_comments_path, notice: "Comment approved."
    end

    def reject
      @comment.update!(status: :rejected)
      redirect_to admin_comments_path, notice: "Comment rejected."
    end

    private

    def set_comment
      @comment = Comment.find(params[:id])
    end
  end
end
