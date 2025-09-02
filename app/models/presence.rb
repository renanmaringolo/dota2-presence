class Presence < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :daily_list

  # Enums
  enum position: { P1: 'P1', P2: 'P2', P3: 'P3', P4: 'P4', P5: 'P5' }
  enum source: { web: 'web' }
  enum status: { confirmed: 'confirmed', cancelled: 'cancelled' }

  # Validations
  validates :position, presence: true, inclusion: { in: positions.keys }
  validates :source, presence: true, inclusion: { in: sources.keys }
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :confirmed_at, presence: true

  # Constraint: uma posição por lista (só confirmadas)
  validates :position, uniqueness: { 
    scope: :daily_list_id,
    conditions: -> { where(status: 'confirmed') },
    message: "já está ocupada"
  }

  # Constraint: um usuário por lista (só confirmadas)  
  validates :user_id, uniqueness: { 
    scope: :daily_list_id,
    conditions: -> { where(status: 'confirmed') },
    message: "já confirmou presença nesta lista"
  }

  # Validações customizadas
  validate :user_cannot_confirm_multiple_times_same_day_type, on: :create
  validate :user_eligible_for_list_type, on: :create
  validate :list_must_be_open, on: :create

  # Scopes
  scope :confirmed, -> { where(status: 'confirmed') }
  scope :for_today, -> { joins(:daily_list).where(daily_lists: { date: Date.current }) }

  # Callback: quando presença é confirmada, verificar se lista ficou cheia
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
    
    # Lista ficou cheia, criar próxima
    daily_list.mark_as_full_and_create_next!
  end
end