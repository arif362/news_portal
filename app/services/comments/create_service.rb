module Comments
  class CreateService < ApplicationService
    def initialize(article:, user:, params:, ip_address: nil)
      @article = article
      @user = user
      @params = params
      @ip_address = ip_address
    end

    def call
      comment = @article.comments.build(@params)
      comment.user = @user
      comment.ip_address = @ip_address
      comment.status = auto_approve? ? :approved : :pending

      if comment.save
        ServiceResult.success(data: comment)
      else
        ServiceResult.failure(errors: comment.errors.full_messages)
      end
    end

    private

    def auto_approve?
      @user.staff?
    end
  end
end
