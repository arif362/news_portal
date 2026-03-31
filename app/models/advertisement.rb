class Advertisement < ApplicationRecord
  extend Mobility
  translates :title, :description

  extend FriendlyId
  friendly_id :title, use: :slugged

  has_one_attached :image

  # Enums
  enum :ad_type, { image: 0, html: 1 }
  enum :placement, { top_banner: 0, sidebar: 1, in_feed: 2, popup: 3 }
  enum :status, { draft: 0, active: 1, paused: 2, expired: 3 }

  # Validations
  validates :title, presence: true
  validates :placement, presence: true
  validates :target_url, presence: true, if: :image?
  validates :embed_code, presence: true, if: :html?

  # Scopes
  scope :active_now, -> {
    active
      .where("starts_at IS NULL OR starts_at <= ?", Time.current)
      .where("ends_at IS NULL OR ends_at >= ?", Time.current)
  }
  scope :for_placement, ->(p) { active_now.where(placement: p).order(:position) }
  scope :ordered, -> { order(:position, created_at: :desc) }

  # Analytics
  def increment_impressions!
    increment!(:impressions_count)
  end

  def increment_clicks!
    increment!(:clicks_count)
  end

  def ctr
    return 0.0 if impressions_count.zero?
    (clicks_count.to_f / impressions_count * 100).round(2)
  end

  def scheduled?
    starts_at.present? || ends_at.present?
  end

  def running?
    active? &&
      (starts_at.nil? || starts_at <= Time.current) &&
      (ends_at.nil? || ends_at >= Time.current)
  end

  def schedule_label
    parts = []
    parts << starts_at.strftime("%b %d, %Y") if starts_at.present?
    parts << ends_at.strftime("%b %d, %Y") if ends_at.present?
    parts.join(" → ")
  end

  def days_remaining
    return nil if ends_at.blank?
    remaining = (ends_at.to_date - Date.current).to_i
    remaining.negative? ? 0 : remaining
  end
end
