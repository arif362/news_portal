class Page < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: [ :slugged, :history ]

  has_rich_text :body

  enum :status, { draft: 0, published: 1 }

  belongs_to :author, class_name: "User", inverse_of: :pages

  validates :title, presence: true, length: { maximum: 255 }
  validates :slug, presence: true, uniqueness: true
  validates :status, presence: true

  scope :published, -> { where(status: :published) }
  scope :navigation, -> { published.where(show_in_navigation: true).order(:position) }
  scope :ordered, -> { order(:position, :title) }
end
