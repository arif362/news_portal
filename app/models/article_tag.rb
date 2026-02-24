class ArticleTag < ApplicationRecord
  belongs_to :article
  belongs_to :tag, counter_cache: :articles_count

  validates :article_id, uniqueness: { scope: :tag_id }
end
