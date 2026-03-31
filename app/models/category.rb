class Category < ApplicationRecord
  extend Mobility
  translates :name, :description, :meta_title, :meta_description

  extend FriendlyId
  friendly_id :name, use: [ :slugged, :history ]

  belongs_to :parent, class_name: "Category", optional: true, inverse_of: :children
  has_many :children, class_name: "Category", foreign_key: :parent_id,
           dependent: :nullify, inverse_of: :parent
  has_many :articles, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 100 }
  validates :slug, presence: true, uniqueness: true
  validate :name_unique_in_locale
  validate :parent_cannot_be_self
  validate :parent_cannot_create_cycle

  scope :active, -> { where(active: true) }
  scope :roots, -> { where(parent_id: nil) }
  scope :ordered, -> { order(:position, Arel.sql("name->>'#{I18n.locale}'")) }
  scope :with_article_counts, -> {
    left_joins(:articles)
      .where(articles: { status: :published })
      .or(left_joins(:articles).where(articles: { id: nil }))
      .group(:id)
      .select("categories.*, COUNT(articles.id) AS published_articles_count")
  }

  private

  def name_unique_in_locale
    return if name.blank?

    scope = self.class.where("name->>? = ?", I18n.locale.to_s, name)
    scope = scope.where.not(id: id) if persisted?
    errors.add(:name, :taken) if scope.exists?
  end

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
