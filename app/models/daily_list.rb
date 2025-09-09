class DailyList < ApplicationRecord
  has_many :presences, dependent: :destroy

  enum :list_type, { ancient: 'ancient', immortal: 'immortal' }
  enum :status, { open: 'open', full: 'full' }

  validates :date, presence: true
  validates :list_type, presence: true, inclusion: { in: list_types.keys }
  validates :sequence_number, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :max_players, presence: true, numericality: { greater_than: 0 }

  validates :sequence_number, uniqueness: {
    scope: [:date, :list_type],
    message: 'já existe para esta data e tipo de lista'
  }

  scope :for_type, ->(type) { where(list_type: type) }
  scope :for_date, ->(date) { where(date: date) }
  scope :current_open, -> { open.order(:sequence_number) }
  scope :historical, -> { full.order(date: :desc, sequence_number: :desc) }

  def self.current_open_list(date, list_type)
    open_list = for_date(date).for_type(list_type).current_open.first
    return open_list if open_list

    next_sequence = for_date(date).for_type(list_type).maximum(:sequence_number) || 0

    create!(
      date: date,
      list_type: list_type,
      sequence_number: next_sequence + 1,
      status: 'open'
    )
  end

  def display_name
    "#{list_type.humanize} ##{sequence_number}"
  end

  def available_positions
    occupied = presences.confirmed.pluck(:position)
    ['P1', 'P2', 'P3', 'P4', 'P5'] - occupied
  end

  def full?
    presences.confirmed.count >= max_players
  end

  def can_user_join?(user)
    return false unless user_eligible?(user)
    return false if user_already_confirmed_today?(user)

    available_positions.any?
  end

  def mark_as_full_and_create_next!
    transaction do
      update!(status: 'full')

      next_list = self.class.current_open_list(date, list_type)

      Rails.logger.info "#{display_name} ficou cheia. Nova lista criada: #{next_list.display_name}"

      next_list
    end
  end

  private

  def user_eligible?(user)
    case list_type
    when 'ancient'
      user.can_join_ancient_list?
    when 'immortal'
      user.can_join_immortal_list?
    end
  end

  def user_already_confirmed_today?(user)
    self.class.for_date(date)
      .for_type(list_type)
      .joins(:presences)
      .exists?(presences: { user: user, status: 'confirmed' })
  end
end
