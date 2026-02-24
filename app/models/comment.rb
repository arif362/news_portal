class Comment < ApplicationRecord
  enum :status, { pending: 0, approved: 1, rejected: 2 }

  belongs_to :article
  belongs_to :user
  belongs_to :parent, class_name: "Comment", optional: true, inverse_of: :replies
  has_many :replies, class_name: "Comment", foreign_key: :parent_id,
           dependent: :destroy, inverse_of: :parent

  validates :body, presence: true, length: { maximum: 2000 }
  validates :status, presence: true
  validate :article_allows_comments
  validate :parent_belongs_to_same_article

  scope :approved, -> { where(status: :approved) }
  scope :pending_review, -> { where(status: :pending) }
  scope :rejected, -> { where(status: :rejected) }
  scope :top_level, -> { where(parent_id: nil) }
  scope :recent, -> { order(created_at: :desc) }

  private

  def article_allows_comments
    errors.add(:base, "Comments are disabled for this article") unless article&.comments_enabled?
  end

  def parent_belongs_to_same_article
    return unless parent_id

    errors.add(:parent, "must belong to the same article") if parent&.article_id != article_id
  end
end
