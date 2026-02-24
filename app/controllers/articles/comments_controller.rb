module Articles
  class CommentsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_article

    def create
      result = Comments::CreateService.call(
        article: @article,
        user: current_user,
        params: comment_params,
        ip_address: request.remote_ip
      )

      if result.success?
        redirect_to article_path(@article, anchor: "comments"),
                    notice: "Comment submitted for review."
      else
        redirect_to article_path(@article, anchor: "comment-form"),
                    alert: result.errors.join(", ")
      end
    end

    def destroy
      @comment = current_user.comments.find(params[:id])
      @comment.destroy
      redirect_to article_path(@article), notice: "Comment deleted."
    end

    private

    def set_article
      @article = Article.published.friendly.find(params[:article_slug])
    end

    def comment_params
      params.require(:comment).permit(:body, :parent_id)
    end
  end
end
