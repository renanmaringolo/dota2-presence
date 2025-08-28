class WhatsappMessage < ApplicationRecord
  include AASM

  STATUSES = %w[pending processed error].freeze

  belongs_to :user, optional: true
  belongs_to :presence, optional: true

  validates :phone, presence: true
  validates :content, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :received_at, presence: true

  scope :recent, -> { order(received_at: :desc) }
  scope :pending, -> { where(status: 'pending') }
  scope :processed, -> { where(status: 'processed') }
  scope :failed, -> { where(status: 'error') }
  scope :today, -> { where(received_at: Date.current.all_day) }

  aasm column: :status do
    state :pending, initial: true
    state :processed
    state :error

    event :mark_as_processed do
      transitions from: :pending, to: :processed
    end

    event :mark_as_error do
      transitions from: [:pending, :processed], to: :error
    end

    event :retry_processing do
      transitions from: :error, to: :pending
    end
  end

  def self.create_from_webhook(phone:, content:)
    create!(
      phone: phone,
      content: content,
      received_at: Time.current,
      status: 'pending'
    )
  end

  def parsed_content
    @parsed_content ||= parse_message
  end

  def valid_format?
    parsed_content[:valid]
  end

  def extracted_nickname
    parsed_content[:nickname]
  end

  def extracted_position
    parsed_content[:position]
  end

  def error_summary
    return nil unless error?
    error_message.presence || "Processing failed"
  end

  private

  def parse_message
    # Pattern: "Nickname/P1" ou "Nickname/p1"
    pattern = /^(\w+)\/(P[1-5])$/i
    match = content.strip.match(pattern)
    
    if match
      {
        valid: true,
        nickname: match[1],
        position: match[2].upcase
      }
    else
      {
        valid: false,
        error: "Invalid format. Expected: Nickname/P1"
      }
    end
  end
end