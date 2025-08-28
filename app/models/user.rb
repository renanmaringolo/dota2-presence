class User < ApplicationRecord
  include AASM

  POSITIONS = %w[P1 P2 P3 P4 P5].freeze
  CATEGORIES = %w[immortal ancient].freeze

  validates :name, presence: true
  validates :nickname, presence: true, uniqueness: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :preferred_position, inclusion: { in: POSITIONS }, allow_nil: true
  validate :positions_are_valid

  has_many :presences, dependent: :destroy
  has_many :daily_lists, through: :presences
  has_many :whatsapp_messages, dependent: :nullify

  scope :active, -> { where(active: true) }
  scope :immortal, -> { where(category: 'immortal') }
  scope :ancient, -> { where(category: 'ancient') }

  def plays_position?(position)
    return false unless position.present?
    positions.include?(position.upcase)
  end

  def display_positions
    positions.join(', ')
  end

  def full_display_name
    "#{name} (#{nickname})"
  end

  private

  def positions_are_valid
    return if positions.blank?
    
    invalid_positions = positions - POSITIONS
    return if invalid_positions.empty?
    
    errors.add(:positions, "contains invalid positions: #{invalid_positions.join(', ')}")
  end
end