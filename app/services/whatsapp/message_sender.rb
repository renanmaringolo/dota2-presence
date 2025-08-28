module Whatsapp
  class MessageSender < ApplicationService
    def initialize(phone, message, user: nil)
      @phone = phone
      @message = message
      @user = user
      super()
    end

    def execute
      return service_response(false, "Phone number required") if phone.blank?
      return service_response(false, "Message content required") if message.blank?

      whatsapp_message = create_whatsapp_message
      send_message(whatsapp_message)
      
      service_response(true, whatsapp_message)
    rescue StandardError => e
      Rails.logger.error "Failed to send WhatsApp message to #{phone}: #{e.message}"
      whatsapp_message&.update!(status: 'failed', error_message: e.message)
      service_response(false, e.message)
    end

    private

    attr_reader :phone, :message, :user

    def create_whatsapp_message
      WhatsappMessage.create!(
        phone: format_phone(phone),
        content: message,
        status: 'pending',
        user: user
      )
    end

    def send_message(whatsapp_message)
      if Rails.env.development?
        simulate_development_send(whatsapp_message)
      else
        send_via_api(whatsapp_message)
      end
    end

    def simulate_development_send(whatsapp_message)
      Rails.logger.info "SIMULATED WhatsApp send to #{whatsapp_message.phone}: #{whatsapp_message.content}"
      whatsapp_message.update!(status: 'sent')
    end

    def send_via_api(whatsapp_message)
      # TODO: Implement actual WhatsApp API integration
      # This will be implemented based on the chosen WhatsApp API provider
      # Examples: Twilio, WhatsApp Business API, etc.
      
      response = make_api_request(whatsapp_message)
      
      if response[:success]
        whatsapp_message.update!(status: 'sent')
      else
        whatsapp_message.update!(
          status: 'failed',
          error_message: response[:error]
        )
        raise StandardError, response[:error]
      end
    end

    def make_api_request(whatsapp_message)
      # Placeholder for actual API implementation
      # Return format: { success: true/false, error: "message" }
      
      if Rails.env.test?
        { success: true }
      else
        raise NotImplementedError, "WhatsApp API integration not yet implemented"
      end
    end

    def format_phone(phone_number)
      # Remove non-numeric characters and ensure proper format
      cleaned = phone_number.gsub(/\D/, '')
      
      # Add country code if missing (assuming Brazil +55)
      cleaned = "55#{cleaned}" unless cleaned.start_with?('55')
      
      "+#{cleaned}"
    end

    class << self
      def send_daily_list(daily_list)
        return service_response(false, "Daily list required") unless daily_list

        message = format_daily_list_message(daily_list)
        results = []

        # Send to all active users
        User.active.find_each do |user|
          next unless user.phone.present?
          
          result = new(user.phone, message, user: user).execute
          results << { user: user.nickname, success: result.success?, message: result.data }
        end

        successful_sends = results.count { |r| r[:success] }
        total_sends = results.size

        Rails.logger.info "Daily list sent: #{successful_sends}/#{total_sends} successful"
        
        service_response(true, {
          total: total_sends,
          successful: successful_sends,
          failed: total_sends - successful_sends,
          results: results
        })
      end

      def send_position_update(presence, action = 'confirmed')
        return service_response(false, "Presence required") unless presence
        return service_response(false, "User phone required") unless presence.user.phone.present?

        message = case action
                 when 'confirmed'
                   "✅ #{presence.user.nickname}, sua presença foi confirmada para #{presence.position}!"
                 when 'cancelled'
                   "❌ #{presence.user.nickname}, sua presença foi cancelada."
                 else
                   "📝 #{presence.user.nickname}, atualização de presença: #{presence.position}"
                 end

        new(presence.user.phone, message, user: presence.user).execute
      end

      private

      def format_daily_list_message(daily_list)
        message = "🎮 *DOTA EVOLUTION - #{daily_list.date.strftime('%d/%m/%Y')}*\n\n"
        message += "Para confirmar presença, responda:\n"
        message += "*SeuNickname/P1* (ou P2, P3, P4, P5)\n\n"
        message += "Posições disponíveis:\n"
        
        DailyList::POSITIONS.each do |position|
          status = daily_list.presences.find_by(position: position)
          if status
            message += "#{position}: ✅ #{status.user.nickname}\n"
          else
            message += "#{position}: ⭕ Disponível\n"
          end
        end
        
        message += "\nPara cancelar: *SeuNickname/cancel*"
        message += "\nPara ver status: *status*"
        
        message
      end
    end
  end
end