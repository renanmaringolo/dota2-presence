module Whatsapp
  class MessageParser < ApplicationService
    PRESENCE_PATTERN = /^(\w+)\/(P[1-5])$/i.freeze
    CANCEL_PATTERN = /^(\w+)\/cancel$/i.freeze
    STATUS_PATTERN = /^(status|lista)$/i.freeze

    def initialize(phone, content, daily_list: nil)
      @phone = phone
      @content = content.to_s.strip
      @daily_list = daily_list || DailyList.find_by(date: Date.current)
      super()
    end

    def execute
      return service_response(false, "No daily list found for today") unless @daily_list

      case message_type
      when :presence
        handle_presence_message
      when :cancel
        handle_cancel_message
      when :status
        handle_status_message
      else
        service_response(false, "Invalid message format. Use: Nickname/P1 or Nickname/cancel")
      end
    rescue StandardError => e
      Rails.logger.error "Failed to parse WhatsApp message from #{@phone}: #{e.message}"
      service_response(false, e.message)
    end

    private

    attr_reader :phone, :content, :daily_list

    def message_type
      return :presence if content.match?(PRESENCE_PATTERN)
      return :cancel if content.match?(CANCEL_PATTERN)
      return :status if content.match?(STATUS_PATTERN)
      
      :unknown
    end

    def handle_presence_message
      match = content.match(PRESENCE_PATTERN)
      nickname = match[1]
      position = match[2].upcase

      user = find_user_by_nickname(nickname)
      return service_response(false, "User '#{nickname}' not found") unless user
      return service_response(false, "User does not play position #{position}") unless user.plays_position?(position)

      confirm_presence(user, position)
    end

    def handle_cancel_message
      match = content.match(CANCEL_PATTERN)
      nickname = match[1]

      user = find_user_by_nickname(nickname)
      return service_response(false, "User '#{nickname}' not found") unless user

      cancel_presence(user)
    end

    def handle_status_message
      status_info = {
        date: daily_list.date,
        status: daily_list.status,
        confirmed_count: daily_list.presences.confirmed.count,
        available_positions: available_positions_list,
        confirmed_players: confirmed_players_list
      }

      service_response(true, status_info)
    end

    def find_user_by_nickname(nickname)
      User.active.find_by("LOWER(nickname) = ?", nickname.downcase)
    end

    def confirm_presence(user, position)
      existing_presence = daily_list.presences.find_by(user: user)
      
      if existing_presence
        if existing_presence.position == position
          return service_response(false, "#{user.nickname} already confirmed for #{position}")
        else
          existing_presence.update!(position: position, confirmed_at: Time.current)
          return service_response(true, "#{user.nickname} moved to #{position}")
        end
      end

      position_taken = daily_list.presences.exists?(position: position)
      return service_response(false, "Position #{position} already taken") if position_taken

      presence = daily_list.presences.create!(
        user: user,
        position: position,
        source: 'whatsapp',
        status: 'confirmed',
        confirmed_at: Time.current
      )

      update_daily_list_summary
      
      service_response(true, "#{user.nickname} confirmed for #{position}")
    end

    def cancel_presence(user)
      presence = daily_list.presences.find_by(user: user)
      return service_response(false, "#{user.nickname} was not confirmed for today") unless presence

      presence.destroy!
      update_daily_list_summary
      
      service_response(true, "#{user.nickname} presence cancelled")
    end

    def available_positions_list
      taken_positions = daily_list.presences.confirmed.pluck(:position)
      DailyList::POSITIONS - taken_positions
    end

    def confirmed_players_list
      daily_list.presences.confirmed.includes(:user).map do |presence|
        {
          nickname: presence.user.nickname,
          position: presence.position,
          category: presence.user.category,
          confirmed_at: presence.confirmed_at
        }
      end
    end

    def update_daily_list_summary
      confirmed_count = daily_list.presences.confirmed.count
      pending_positions = available_positions_list
      
      summary = daily_list.summary.merge(
        confirmed_presences: confirmed_count,
        pending_positions: pending_positions,
        last_updated: Time.current.iso8601
      )
      
      daily_list.update!(summary: summary)
    end
  end
end