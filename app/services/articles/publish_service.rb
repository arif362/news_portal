module Articles
  class PublishService < ApplicationService
    def initialize(article:, user:)
      @article = article
      @user = user
    end

    def call
      validate_permissions!
      validate_article!

      @article.update!(
        status: :published,
        published_at: @article.published_at || Time.current
      )

      ServiceResult.success(data: @article)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult.failure(errors: e.record.errors.full_messages)
    rescue StandardError => e
      ServiceResult.failure(errors: [ e.message ])
    end

    private

    def validate_permissions!
      raise "Only editors and admins can publish articles" unless @user.editor? || @user.admin?
    end

    def validate_article!
      raise "Article must have a title" if @article.title.blank?
      raise "Article must have a body" if @article.body.blank?
      raise "Article must have a category" if @article.category_id.blank?
    end
  end
end
