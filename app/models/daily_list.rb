class DailyList < ApplicationRecord
  # Associations
  has_many :presences, dependent: :destroy

  # Enums
  enum list_type: { ancient: 'ancient', immortal: 'immortal' }
  enum status: { open: 'open', full: 'full' }

  # Validations
  validates :date, presence: true
  validates :list_type, presence: true, inclusion: { in: list_types.keys }
  validates :sequence_number, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :max_players, presence: true, numericality: { greater_than: 0 }
  
  validates :sequence_number, uniqueness: { 
    scope: [:date, :list_type],
    message: "já existe para esta data e tipo de lista"
  }

  # Scopes
  scope :for_type, ->(type) { where(list_type: type) }
  scope :for_date, ->(date) { where(date: date) }
  scope :current_open, -> { open.order(:sequence_number) }
  scope :historical, -> { full.order(date: :desc, sequence_number: :desc) }

  # Método principal: sempre retorna a lista OPEN atual ou cria nova
  def self.current_open_list(date, list_type)
    # Buscar lista OPEN existente
    open_list = for_date(date).for_type(list_type).current_open.first
    return open_list if open_list
    
    # Se não existe OPEN, criar nova sequência
    next_sequence = for_date(date).for_type(list_type).maximum(:sequence_number) || 0
    
    create!(
      date: date,
      list_type: list_type,
      sequence_number: next_sequence + 1,
      status: 'open'
    )
  end

  # Métodos de negócio
  def display_name
    "#{list_type.humanize} ##{sequence_number}"
  end

  def available_positions
    occupied = presences.confirmed.pluck(:position)
    %w[P1 P2 P3 P4 P5] - occupied
  end

  def full?
    presences.confirmed.count >= max_players
  end

  def can_user_join?(user)
    return false unless user_eligible?(user)
    return false if user_already_confirmed_today?(user)
    available_positions.any?
  end

  # Quando lista enche, marca como full e cria próxima automaticamente
  def mark_as_full_and_create_next!
    transaction do
      # Marcar atual como FULL
      update!(status: 'full')
      
      # Criar próxima lista OPEN
      next_list = self.class.current_open_list(date, list_type)
      
      Rails.logger.info "#{display_name} ficou cheia. Nova lista criada: #{next_list.display_name}"
      
      next_list
    end
  end

  private

  def user_eligible?(user)
    case list_type
    when 'ancient'
      user.can_join_ancient_list?   # Todos podem (inclusive smurfs)
    when 'immortal' 
      user.can_join_immortal_list?  # Só Divine+
    end
  end

  def user_already_confirmed_today?(user)
    # Verificar se usuário já confirmou em QUALQUER lista do mesmo tipo hoje
    self.class.for_date(date)
             .for_type(list_type)
             .joins(:presences)
             .where(presences: { user: user, status: 'confirmed' })
             .exists?
  end
end