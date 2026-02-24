class Tag < ApplicationRecord
  extend Mobility
  translates :name

  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :article_tags, dependent: :destroy
  has_many :articles, through: :article_tags

  validates :name, presence: true, length: { maximum: 50 }
  validates :slug, presence: true, uniqueness: true
  validate :name_unique_in_locale

  scope :popular, -> { order(articles_count: :desc) }
  scope :ordered, -> { order(Arel.sql("name->>'#{I18n.locale}'")) }

  before_validation :normalize_name

  private

  def name_unique_in_locale
    return if name.blank?

    scope = self.class.where("LOWER(name->>?) = LOWER(?)", I18n.locale.to_s, name)
    scope = scope.where.not(id: id) if persisted?
    errors.add(:name, :taken) if scope.exists?
  end

  def normalize_name
    self.name = name&.strip&.downcase
  end
end
