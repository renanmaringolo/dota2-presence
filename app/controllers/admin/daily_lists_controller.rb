module Admin
  class DailyListsController < BaseController
    before_action :set_daily_list, only: [:show, :update, :destroy, :send_to_whatsapp]

    def index
      daily_lists = DailyList.includes(presences: :user)
                            .order(date: :desc)
                            .limit(30)

      if params[:status].present?
        daily_lists = daily_lists.where(status: params[:status])
      end

      render_success({
        daily_lists: daily_lists.map(&method(:daily_list_json)),
        total: daily_lists.count
      })
    end

    def show
      render_success(daily_list_detailed_json(@daily_list))
    end

    def create
      date = Date.parse(params[:date] || Date.current.to_s)
      
      result = DailyListGenerator.new(date: date).execute
      
      if result.success?
        render_success(daily_list_json(result.data), 'Daily list created successfully')
      else
        render_error(result.data)
      end
    rescue Date::Error
      render_error('Invalid date format')
    end

    def update
      if @daily_list.update(daily_list_params)
        render_success(daily_list_json(@daily_list), 'Daily list updated successfully')
      else
        render_error(@daily_list.errors.full_messages.join(', '))
      end
    end

    def destroy
      @daily_list.destroy!
      render_success(nil, 'Daily list deleted successfully')
    end

    def send_to_whatsapp
      result = Whatsapp::MessageSender.send_daily_list(@daily_list)
      
      if result.success?
        @daily_list.update!(status: 'sent')
        render_success(result.data, 'Daily list sent to WhatsApp')
      else
        render_error(result.data)
      end
    end

    private

    def set_daily_list
      @daily_list = DailyList.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_error('Daily list not found', :not_found)
    end

    def daily_list_params
      params.require(:daily_list).permit(:status, :content, summary: {})
    end

    def daily_list_json(daily_list)
      {
        id: daily_list.id,
        date: daily_list.date,
        status: daily_list.status,
        summary: daily_list.summary,
        presences_count: daily_list.presences.confirmed.count,
        available_positions: available_positions(daily_list),
        created_at: daily_list.created_at,
        updated_at: daily_list.updated_at
      }
    end

    def daily_list_detailed_json(daily_list)
      {
        id: daily_list.id,
        date: daily_list.date,
        status: daily_list.status,
        content: daily_list.content,
        summary: daily_list.summary,
        presences: daily_list.presences.confirmed.includes(:user).map do |presence|
          {
            id: presence.id,
            user: {
              id: presence.user.id,
              nickname: presence.user.nickname,
              name: presence.user.name,
              category: presence.user.category
            },
            position: presence.position,
            source: presence.source,
            confirmed_at: presence.confirmed_at,
            notes: presence.notes
          }
        end,
        available_positions: available_positions(daily_list),
        created_at: daily_list.created_at,
        updated_at: daily_list.updated_at
      }
    end

    def available_positions(daily_list)
      taken_positions = daily_list.presences.confirmed.pluck(:position)
      DailyList::POSITIONS - taken_positions
    end
  end
end