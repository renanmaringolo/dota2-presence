class DailyList::GetCurrentListsOperation < ApplicationOperation
  def initialize(params)
    super
    @user = params[:user]
    @date = params[:date] || Date.current
  end

  def call
    # Buscar ou criar listas OPEN atuais
    ancient_list = DailyList.current_open_list(@date, 'ancient')
    immortal_list = DailyList.current_open_list(@date, 'immortal')

    # Buscar estatísticas do dia
    daily_stats = calculate_daily_stats

    success_response({
      current_lists: {
        ancient: serialize_current_list(ancient_list),
        immortal: serialize_current_list(immortal_list)
      },
      daily_stats: daily_stats,
      historical_summary: get_recent_completed_lists
    })
  end

  private

  def serialize_current_list(list)
    {
      id: list.id,
      date: list.date,
      list_type: list.list_type,
      sequence_number: list.sequence_number,
      display_name: list.display_name,
      status: list.status,
      available_positions: list.available_positions,
      confirmed_players: list.presences.confirmed.includes(:user).map do |presence|
        {
          position: presence.position,
          user: {
            nickname: presence.user.nickname,
            rank: presence.user.display_rank,
            confirmed_at: presence.confirmed_at
          }
        }
      end,
      user_status: calculate_user_status_for_list(list)
    }
  end

  def calculate_user_status_for_list(list)
    return { can_join: false, reason: 'not_authenticated' } unless @user

    # Verificar elegibilidade por rank
    eligible = case list.list_type
               when 'ancient' then @user.can_join_ancient_list?
               when 'immortal' then @user.can_join_immortal_list?
               end

    return { can_join: false, reason: 'not_eligible' } unless eligible

    # Verificar se já confirmou em outra lista do mesmo tipo hoje
    existing_presence = find_user_presence_for_list_type(list.list_type)
    if existing_presence
      return {
        can_join: false,
        reason: 'already_confirmed_today',
        confirmed_list: existing_presence.daily_list.display_name,
        position: existing_presence.position
      }
    end

    # Verificar se lista atual tem vagas
    return { can_join: false, reason: 'list_full' } if list.available_positions.empty?

    {
      can_join: true,
      available_positions: list.available_positions,
      is_current_open_list: true
    }
  end

  def find_user_presence_for_list_type(list_type)
    DailyList.for_date(@date)
             .for_type(list_type)
             .joins(:presences)
             .where(presences: { user: @user, status: 'confirmed' })
             .first&.presences&.find_by(user: @user)
  end

  def calculate_daily_stats
    ancient_lists = DailyList.for_date(@date).for_type('ancient')
    immortal_lists = DailyList.for_date(@date).for_type('immortal')

    {
      ancient_count: ancient_lists.count,
      immortal_count: immortal_lists.count,
      total_players_today: Presence.joins(:daily_list)
                                  .where(daily_lists: { date: @date })
                                  .where(status: 'confirmed')
                                  .count,
      current_sequence: {
        ancient: ancient_lists.maximum(:sequence_number) || 0,
        immortal: immortal_lists.maximum(:sequence_number) || 0
      }
    }
  end

  def get_recent_completed_lists
    DailyList.where(date: (@date - 7.days)..@date)
             .full
             .includes(presences: :user)
             .order(date: :desc, sequence_number: :desc)
             .limit(10)
             .map do |list|
               {
                 id: list.id,
                 display_name: list.display_name,
                 date: list.date,
                 completed_at: list.updated_at, # Quando ficou full
                 players: list.presences.confirmed.includes(:user).map do |p|
                   "#{p.user.nickname} (#{p.position})"
                 end
               }
             end
  end
end