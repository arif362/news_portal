class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: [ :slugged, :history ]

  belongs_to :parent, class_name: "Category", optional: true, inverse_of: :children
  has_many :children, class_name: "Category", foreign_key: :parent_id,
           dependent: :nullify, inverse_of: :parent
  has_many :articles, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :slug, presence: true, uniqueness: true
  validate :parent_cannot_be_self
  validate :parent_cannot_create_cycle

  scope :active, -> { where(active: true) }
  scope :roots, -> { where(parent_id: nil) }
  scope :ordered, -> { order(:position, :name) }
  scope :with_article_counts, -> {
    left_joins(:articles)
      .where(articles: { status: :published })
      .or(left_joins(:articles).where(articles: { id: nil }))
      .group(:id)
      .select("categories.*, COUNT(articles.id) AS published_articles_count")
  }

  private

  def parent_cannot_be_self
    errors.add(:parent_id, "cannot be self") if parent_id.present? && parent_id == id
  end

  def parent_cannot_create_cycle
    return unless parent_id

    current = parent
    while current
      if current.id == id
        errors.add(:parent_id, "creates a cycle")
        break
      end
      current = current.parent
    end
  end
end
