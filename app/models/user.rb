class User < ApplicationRecord
  has_secure_password

  enum :role, { reader: 0, author: 1, editor: 2, admin: 3 }

  has_many :articles, foreign_key: :author_id, dependent: :restrict_with_error, inverse_of: :author
  has_many :comments, dependent: :destroy
  has_many :pages, foreign_key: :author_id, dependent: :restrict_with_error, inverse_of: :author
  has_one_attached :avatar

  validates :email, presence: true, uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: { case_sensitive: false },
            format: { with: /\A[a-zA-Z0-9_]+\z/ }, length: { in: 3..30 }
  validates :first_name, :last_name, presence: true, length: { maximum: 50 }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }
  validates :role, presence: true

  scope :active, -> { where(active: true) }
  scope :staff, -> { where(role: [ :author, :editor, :admin ]) }

  before_save :downcase_email

  def full_name
    "#{first_name} #{last_name}"
  end

  def full_name_bn
    if first_name_bn.present? && last_name_bn.present?
      "#{first_name_bn} #{last_name_bn}"
    else
      full_name
    end
  end

  def localized_full_name
    I18n.locale == :bn ? full_name_bn : full_name
  end

  def localized_role
    I18n.t("roles.#{role}")
  end

  def staff?
    author? || editor? || admin?
  end

  def generate_password_reset_token!
    update!(
      password_reset_token: SecureRandom.urlsafe_base64(32),
      password_reset_sent_at: Time.current
    )
  end

  def password_reset_token_valid?
    password_reset_sent_at.present? && password_reset_sent_at > 2.hours.ago
  end

  def clear_password_reset_token!
    update!(password_reset_token: nil, password_reset_sent_at: nil)
  end

  def track_sign_in!(ip:)
    update!(
      last_sign_in_at: Time.current,
      last_sign_in_ip: ip,
      sign_in_count: sign_in_count + 1
    )
  end

  private

  def downcase_email
    self.email = email.downcase.strip
  end
end
