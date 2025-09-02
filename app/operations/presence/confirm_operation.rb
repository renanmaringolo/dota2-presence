class Presence::ConfirmOperation < ApplicationOperation
  class ValidationError < StandardError; end

  def initialize(params)
    super
    @user = params[:user]
    @position = params[:position]
    @list_type = params[:list_type]
    @date = params[:date] || Date.current
  end

  def call
    validate_params!
    find_current_open_list!
    validate_business_rules!
    
    create_presence!
    handle_list_auto_progression!
    
    success_response({
      presence: serialize_presence,
      updated_list: serialize_list(@daily_list.reload),
      next_list_created: @next_list_created,
      next_list: @next_list ? serialize_list(@next_list) : nil
    })
  rescue ValidationError => e
    error_response(e.message, 'validation_error')
  end

  private

  def validate_params!
    raise ValidationError, "Usuário é obrigatório" unless @user
    raise ValidationError, "Posição é obrigatória" if @position.blank?
    raise ValidationError, "Tipo de lista é obrigatório" if @list_type.blank?
    raise ValidationError, "Posição inválida" unless %w[P1 P2 P3 P4 P5].include?(@position)
    raise ValidationError, "Tipo de lista inválido" unless %w[ancient immortal].include?(@list_type)
  end

  def find_current_open_list!
    @daily_list = DailyList.current_open_list(@date, @list_type)
    raise ValidationError, "Lista não encontrada" unless @daily_list
  end

  def validate_business_rules!
    # 1. Usuário pode participar deste tipo de lista?
    unless @daily_list.can_user_join?(@user)
      case @list_type
      when 'ancient'
        raise ValidationError, "Erro interno - todos podem participar da lista Ancient"
      when 'immortal'
        raise ValidationError, "Você precisa ser Divine+ para participar da lista Immortal"
      end
    end

    # 2. Posição está disponível na lista atual?
    unless @daily_list.available_positions.include?(@position)
      raise ValidationError, "Posição #{@position} já está ocupada"
    end

    # 3. Lista está aberta?
    unless @daily_list.status == 'open'
      raise ValidationError, "Lista não está aberta para confirmações"
    end

    # 4. Usuário já confirmou em outra lista do mesmo tipo hoje?
    existing_presence = find_existing_presence_same_type
    if existing_presence
      raise ValidationError, "Você já confirmou presença na #{existing_presence.daily_list.display_name} hoje"
    end
  end

  def find_existing_presence_same_type
    DailyList.for_date(@date)
             .for_type(@list_type)
             .joins(:presences)
             .where(presences: { user: @user, status: 'confirmed' })
             .first&.presences&.find_by(user: @user)
  end

  def create_presence!
    @presence = Presence.create!(
      user: @user,
      daily_list: @daily_list,
      position: @position,
      source: 'web',
      status: 'confirmed',
      confirmed_at: Time.current
    )

    Rails.logger.info "Presença confirmada: #{@user.nickname} na posição #{@position} da #{@daily_list.display_name}"
  end

  def handle_list_auto_progression!
    @next_list_created = false

    # Verificar se lista ficou cheia após confirmação
    if @daily_list.reload.full?
      @next_list = @daily_list.mark_as_full_and_create_next!
      @next_list_created = true

      Rails.logger.info "Auto-progressão: #{@daily_list.display_name} → #{@next_list.display_name}"
    end
  end

  def serialize_presence
    {
      id: @presence.id,
      position: @presence.position,
      confirmed_at: @presence.confirmed_at,
      user: {
        nickname: @presence.user.nickname,
        rank: @presence.user.display_rank
      }
    }
  end

  def serialize_list(list)
    {
      id: list.id,
      display_name: list.display_name,
      status: list.status,
      available_positions: list.available_positions,
      players_count: list.presences.confirmed.count
    }
  end
end