class Presence < ApplicationRecord
  belongs_to :user
  belongs_to :daily_list

  enum position: { P1: 'P1', P2: 'P2', P3: 'P3', P4: 'P4', P5: 'P5' }
  enum source: { web: 'web' }
  enum status: { confirmed: 'confirmed', cancelled: 'cancelled' }

  validates :position, presence: true, inclusion: { in: positions.keys }
  validates :source, presence: true, inclusion: { in: sources.keys }
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :confirmed_at, presence: true, if: -> { confirmed? }

  validates :position, uniqueness: { 
    scope: :daily_list_id,
    conditions: -> { where(status: 'confirmed') },
    message: "já está ocupada"
  }

  validates :user_id, uniqueness: { 
    scope: :daily_list_id,
    message: "já tem presença registrada nesta lista"
  }

  validate :user_cannot_confirm_multiple_times_same_day_type, if: -> { confirmed? && status_changed? }
  validate :user_eligible_for_list_type, if: -> { confirmed? && status_changed? }
  validate :list_must_be_open, if: -> { confirmed? && status_changed? }

  scope :confirmed, -> { where(status: 'confirmed') }
  scope :cancelled, -> { where(status: 'cancelled') }
  scope :for_today, -> { joins(:daily_list).where(daily_lists: { date: Date.current }) }

  def toggle_to_confirmed!(position = nil)
    update!(
      status: 'confirmed',
      position: position || self.position,
      confirmed_at: Time.current,
      notes: nil
    )
  end

  def toggle_to_cancelled!(reason = "Cancelado pelo usuário")
    update!(
      status: 'cancelled',
      notes: "#{reason} em #{Time.current}"
    )
  end

  after_create :check_if_list_full

  private

  def user_cannot_confirm_multiple_times_same_day_type
    return unless daily_list && user
    
    existing_confirmation = DailyList.for_date(daily_list.date)
                                    .for_type(daily_list.list_type)
                                    .joins(:presences)
                                    .where(presences: { user: user, status: 'confirmed' })
                                    .where.not(id: daily_list_id)
                                    .exists?
    
    if existing_confirmation
      errors.add(:user, "já confirmou presença em outra lista #{daily_list.list_type.humanize} hoje")
    end
  end

  def user_eligible_for_list_type
    return unless daily_list && user
    
    case daily_list.list_type
    when 'ancient'
      return if user.can_join_ancient_list?
      errors.add(:user, "não pode participar da lista Ancient")
    when 'immortal'
      return if user.can_join_immortal_list?
      errors.add(:user, "precisa ser Divine+ para lista Immortal")
    end
  end

  def list_must_be_open
    return unless daily_list
    return if daily_list.status == 'open'
    
    errors.add(:daily_list, "não está aberta para confirmações")
  end

  def check_if_list_full
    return unless daily_list.reload.full?
    
    daily_list.mark_as_full_and_create_next!
  end
end
