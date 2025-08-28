class Presence < ApplicationRecord
  include AASM

  STATUSES = %w[confirmed maybe cancelled].freeze
  SOURCES = %w[web whatsapp].freeze

  belongs_to :user
  belongs_to :daily_list

  validates :position, presence: true, inclusion: { in: User::POSITIONS }
  validates :status, inclusion: { in: STATUSES }
  validates :source, inclusion: { in: SOURCES }
  validates :user_id, uniqueness: { scope: :daily_list_id, message: "already has presence for this daily list" }
  validates :position, uniqueness: { scope: :daily_list_id, message: "already taken for this daily list" }
  validate :user_can_play_position

  scope :confirmed, -> { where(status: 'confirmed') }
  scope :maybe, -> { where(status: 'maybe') }
  scope :cancelled, -> { where(status: 'cancelled') }
  scope :from_web, -> { where(source: 'web') }
  scope :from_whatsapp, -> { where(source: 'whatsapp') }

  aasm column: :status do
    state :confirmed, initial: true
    state :maybe
    state :cancelled

    event :confirm do
      transitions from: [:maybe, :cancelled], to: :confirmed
    end

    event :mark_as_maybe do
      transitions from: [:confirmed, :cancelled], to: :maybe
    end

    event :cancel do
      transitions from: [:confirmed, :maybe], to: :cancelled
    end
  end

  def display_name
    "#{user.full_display_name} - #{position}"
  end

  def confirmed?
    status == 'confirmed'
  end

  def from_whatsapp?
    source == 'whatsapp'
  end

  def from_web?
    source == 'web'
  end

  private

  def user_can_play_position
    return unless user && position
    return if user.plays_position?(position)
    
    errors.add(:position, "#{user.name} cannot play position #{position}")
  end
end