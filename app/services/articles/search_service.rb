module Articles
  class SearchService < ApplicationService
    def initialize(query:)
      @query = query&.strip
    end

    def call
      return Article.none if @query.blank?

      Article.published
             .search_by_text(@query)
             .includes(:category, :author, :tags)
    end
  end
end
