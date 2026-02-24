class Tag < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :article_tags, dependent: :destroy
  has_many :articles, through: :article_tags

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }
  validates :slug, presence: true, uniqueness: true

  scope :popular, -> { order(articles_count: :desc) }
  scope :ordered, -> { order(:name) }

  before_validation :normalize_name

  private

  def normalize_name
    self.name = name&.strip&.downcase
  end
end
