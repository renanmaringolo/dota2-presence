module Admin
  class DashboardController < BaseController
    def index
      today = Date.current
      
      # Today's stats
      today_list = DailyList.find_by(date: today)
      today_presences = today_list&.presences&.confirmed || Presence.none
      
      # Recent activity
      recent_lists = DailyList.includes(:presences)
                             .where('date >= ?', 7.days.ago)
                             .order(date: :desc)
      
      # User stats
      total_users = User.count
      active_users = User.active.count
      immortal_users = User.immortal.active.count
      ancient_users = User.ancient.active.count
      
      # Weekly presence stats
      weekly_presences = Presence.joins(:daily_list)
                                .where(daily_lists: { date: 1.week.ago..today })
                                .confirmed
                                .count
      
      render_success({
        today: {
          date: today,
          daily_list_id: today_list&.id,
          daily_list_status: today_list&.status,
          confirmed_presences: today_presences.count,
          available_positions: available_positions_today(today_list),
          confirmed_players: today_presences.includes(:user).map do |presence|
            {
              nickname: presence.user.nickname,
              position: presence.position,
              category: presence.user.category,
              confirmed_at: presence.confirmed_at
            }
          end
        },
        stats: {
          users: {
            total: total_users,
            active: active_users,
            immortals: immortal_users,
            ancients: ancient_users,
            inactive: total_users - active_users
          },
          activity: {
            weekly_presences: weekly_presences,
            recent_lists_count: recent_lists.count,
            avg_daily_presences: recent_lists.any? ? (weekly_presences.to_f / recent_lists.count).round(1) : 0
          }
        },
        recent_activity: recent_lists.limit(5).map do |daily_list|
          {
            id: daily_list.id,
            date: daily_list.date,
            status: daily_list.status,
            presences_count: daily_list.presences.confirmed.count,
            created_at: daily_list.created_at
          }
        end
      })
    end

    private

    def available_positions_today(daily_list)
      return DailyList::POSITIONS.dup unless daily_list
      
      taken_positions = daily_list.presences.confirmed.pluck(:position)
      DailyList::POSITIONS - taken_positions
    end
  end
end