class Article < ApplicationRecord
  extend Mobility
  translates :title, :excerpt, :meta_title, :meta_description, :meta_keywords

  extend FriendlyId
  friendly_id :title, use: [ :slugged, :history ]

  include PgSearch::Model

  has_rich_text :body_en
  has_rich_text :body_bn
  has_one_attached :featured_image

  enum :status, { draft: 0, published: 1, archived: 2 }

  belongs_to :category
  belongs_to :author, class_name: "User", inverse_of: :articles
  has_many :article_tags, dependent: :destroy
  has_many :tags, through: :article_tags
  has_many :comments, dependent: :destroy

  pg_search_scope :search_by_text,
    using: {
      tsearch: { prefix: true, dictionary: "english", tsvector_column: "search_vector" }
    }

  validates :title, presence: true, length: { maximum: 255 }
  validates :slug, presence: true, uniqueness: true
  validates :status, presence: true
  validates :excerpt, length: { maximum: 500 }
  validates :published_at, presence: true, if: :published?

  scope :published, -> { where(status: :published).where("published_at <= ?", Time.current) }
  scope :drafts, -> { where(status: :draft) }
  scope :archived, -> { where(status: :archived) }
  scope :featured, -> { published.where(featured: true) }
  scope :breaking_news, -> { published.where(breaking: true) }
  scope :recent, -> { published.order(published_at: :desc) }
  scope :popular, -> { published.order(views_count: :desc) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :by_author, ->(author_id) { where(author_id: author_id) }
  scope :by_tag, ->(tag_id) { joins(:article_tags).where(article_tags: { tag_id: tag_id }) }

  before_validation :set_published_at, if: -> { status_changed? && published? }

  def body
    locale_body = send(:"body_#{I18n.locale}")
    locale_body.present? ? locale_body : body_en
  end

  def increment_views!
    increment!(:views_count) # rubocop:disable Rails/SkipsModelValidations
  end

  def reading_time
    words = body&.to_plain_text&.split&.size || 0
    [ (words / 200.0).ceil, 1 ].max
  end

  private

  def set_published_at
    self.published_at ||= Time.current
  end
end
