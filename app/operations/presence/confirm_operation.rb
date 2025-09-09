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

    find_or_create_presence!
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
    raise ValidationError, 'Usuário é obrigatório' unless @user
    raise ValidationError, 'Posição é obrigatória' if @position.blank?
    raise ValidationError, 'Tipo de lista é obrigatório' if @list_type.blank?
    raise ValidationError, 'Posição inválida' unless ['P1', 'P2', 'P3', 'P4', 'P5'].include?(@position)
    raise ValidationError, 'Tipo de lista inválido' unless ['ancient', 'immortal'].include?(@list_type)
  end

  def find_current_open_list!
    @daily_list = DailyList.current_open_list(@date, @list_type)
    raise ValidationError, 'Lista não encontrada' unless @daily_list
  end

  def validate_business_rules!
    unless @daily_list.can_user_join?(@user)
      case @list_type
      when 'ancient'
        raise ValidationError, 'Erro interno - todos podem participar da lista Ancient'
      when 'immortal'
        raise ValidationError, 'Você precisa ser Divine+ para participar da lista Immortal'
      end
    end

    unless @daily_list.available_positions.include?(@position)
      raise ValidationError, "Posição #{@position} já está ocupada"
    end

    raise ValidationError, 'Lista não está aberta para confirmações' unless @daily_list.status == 'open'

    existing_presence = find_existing_confirmed_presence
    return unless existing_presence

    raise ValidationError,
          "Você já tem presença confirmada na #{existing_presence.daily_list.display_name}. Cancele primeiro para confirmar em outra lista."
  end

  def find_existing_confirmed_presence
    Presence.joins(:daily_list)
      .where(user: @user, status: 'confirmed')
      .where(daily_lists: { status: 'open' })
      .first
  end

  def find_or_create_presence!
    @presence = @daily_list.presences.find_by(user: @user)

    if @presence
      if @presence.status == 'cancelled'
        @presence.toggle_to_confirmed!(@position)
        Rails.logger.info "Presença reativada: #{@user.nickname} na posição #{@position} da #{@daily_list.display_name}"
      elsif @presence.position != @position
        @presence.update!(position: @position)
        Rails.logger.info "Posição atualizada: #{@user.nickname} #{@presence.position} → #{@position} na #{@daily_list.display_name}"
      end
    else
      @presence = Presence.create!(
        user: @user,
        daily_list: @daily_list,
        position: @position,
        source: 'web',
        status: 'confirmed',
        confirmed_at: Time.current
      )
      Rails.logger.info "Nova presença criada: #{@user.nickname} na posição #{@position} da #{@daily_list.display_name}"
    end
  end

  def handle_list_auto_progression!
    @next_list_created = false

    return unless @daily_list.reload.full?

    @next_list = @daily_list.mark_as_full_and_create_next!
    @next_list_created = true

    Rails.logger.info "Auto-progressão: #{@daily_list.display_name} → #{@next_list.display_name}"
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
