class DailyList < ApplicationRecord
  include AASM

  POSITIONS = %w[P1 P2 P3 P4 P5].freeze

  validates :date, presence: true, uniqueness: true

  has_many :presences, dependent: :destroy
  has_many :users, through: :presences
  has_many :whatsapp_messages, dependent: :nullify

  scope :recent, -> { order(date: :desc) }
  scope :for_date, ->(date) { where(date: date) }

  aasm column: :status do
    state :generated, initial: true
    state :sent
    state :closed

    event :mark_as_sent do
      transitions from: :generated, to: :sent
    end

    event :close_list do
      transitions from: [:generated, :sent], to: :closed
    end

    event :reopen do
      transitions from: :closed, to: :sent
    end
  end

  def self.for_today
    find_or_create_by(date: Date.current)
  end

  def confirmed_presences
    presences.confirmed
  end

  def immortals_count
    confirmed_presences.joins(:user).where(users: { category: 'immortal' }).count
  end

  def ancients_count
    confirmed_presences.joins(:user).where(users: { category: 'ancient' }).count
  end

  def positions_filled
    confirmed_presences.pluck(:position).uniq.sort
  end

  def available_positions
    POSITIONS - positions_filled
  end

  def full_summary
    {
      total: confirmed_presences.count,
      immortals: immortals_count,
      ancients: ancients_count,
      positions_filled: positions_filled.count,
      available_positions: available_positions
    }
  end

  def formatted_for_whatsapp
    return content if content.present?
    generate_whatsapp_content
  end

  private

  def generate_whatsapp_content
    immortals = User.active.immortal.order(:name)
    ancients = User.active.ancient.order(:name)
    
    content = []
    content << "🎯 *DOTA EVOLUTION PRESENCE - #{date.strftime('%d/%m')}*"
    content << ""
    
    if immortals.any?
      content << "📋 *LISTA IMMORTAL*"
      immortals.each_with_index do |user, index|
        status = user_status_for_list(user)
        content << "#{index + 1}. #{user.full_display_name} #{status}"
      end
      content << ""
    end
    
    if ancients.any?
      content << "📋 *LISTA ANCIENT*"
      ancients.each_with_index do |user, index|
        status = user_status_for_list(user)
        content << "#{index + 1}. #{user.full_display_name} #{status}"
      end
      content << ""
    end
    
    content << "🔗 *Confirmar presença:*"
    content << "#{Rails.application.routes.url_helpers.presence_url(date: date.strftime('%Y-%m-%d'))}"
    content << ""
    content << "💬 *Ou responda:* Nickname/Posição (ex: Metallica/P1)"
    
    content.join("\n")
  end

  def user_status_for_list(user)
    presence = presences.find_by(user: user)
    return "✅ #{presence.position}" if presence&.confirmed?
    return "❓ #{presence.status}" if presence
    "⚪"
  end
end