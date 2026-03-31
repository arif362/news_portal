class Page < ApplicationRecord
  extend Mobility
  translates :title, :meta_title, :meta_description

  extend FriendlyId
  friendly_id :title, use: [ :slugged, :history ]

  has_rich_text :body_en
  has_rich_text :body_bn

  enum :status, { draft: 0, published: 1 }

  belongs_to :author, class_name: "User", inverse_of: :pages

  validates :title, presence: true, length: { maximum: 255 }
  validates :slug, presence: true, uniqueness: true
  validates :status, presence: true

  scope :published, -> { where(status: :published) }
  scope :navigation, -> { published.where(show_in_navigation: true).order(:position) }
  scope :ordered, -> { order(:position, Arel.sql("title->>'#{I18n.locale}'")) }

  def body
    locale_body = send(:"body_#{I18n.locale}")
    locale_body.present? ? locale_body : body_en
  end
end
