class WhatsappWebhookController < ApplicationController
  skip_before_action :verify_authenticity_token, if: :json_request?
  before_action :verify_webhook_signature, only: [:receive_message]

  def receive_message
    phone = extract_phone_from_webhook
    content = extract_content_from_webhook

    return render_error('Invalid webhook data') if phone.blank? || content.blank?

    # Save the incoming message
    whatsapp_message = WhatsappMessage.create!(
      phone: phone,
      content: content,
      status: 'received',
      received_at: Time.current
    )

    # Process the message
    result = Whatsapp::MessageParser.new(phone, content).execute
    
    if result.success?
      # Update the message with associated user if found
      if result.data.is_a?(Hash) && result.data[:user_id]
        whatsapp_message.update!(user_id: result.data[:user_id])
      end
      
      # Send confirmation back to user if configured
      if should_send_confirmation?(result)
        confirmation_message = build_confirmation_message(result)
        Whatsapp::MessageSender.new(phone, confirmation_message).execute
      end
      
      render_success({ message_id: whatsapp_message.id, processed: true })
    else
      # Send error message back to user
      error_message = "❌ #{result.data}\n\nFormato correto: NickName/P1 (ou P2, P3, P4, P5)\nPara cancelar: NickName/cancel"
      Whatsapp::MessageSender.new(phone, error_message).execute
      
      render_success({ message_id: whatsapp_message.id, processed: false, error: result.data })
    end

  rescue StandardError => e
    Rails.logger.error "WhatsApp webhook error: #{e.message}"
    render_error('Internal server error', :internal_server_error)
  end

  def verify_webhook
    # WhatsApp webhook verification for setup
    verify_token = params['hub.verify_token']
    challenge = params['hub.challenge']
    
    if verify_token == webhook_verify_token
      render plain: challenge
    else
      render_error('Invalid verify token', :forbidden)
    end
  end

  private

  def verify_webhook_signature
    return true if Rails.env.development? # Skip verification in development
    
    signature = request.headers['X-Hub-Signature-256']
    return render_error('Missing signature', :unauthorized) unless signature
    
    expected_signature = calculate_webhook_signature(request.body.read)
    
    unless secure_compare(signature, expected_signature)
      render_error('Invalid signature', :unauthorized)
    end
  end

  def calculate_webhook_signature(payload)
    secret = webhook_secret
    "sha256=#{OpenSSL::HMAC.hexdigest('SHA256', secret, payload)}"
  end

  def secure_compare(a, b)
    return false unless a.bytesize == b.bytesize
    
    l = a.unpack("C#{a.bytesize}")
    res = 0
    b.each_byte { |byte| res |= byte ^ l.shift }
    res == 0
  end

  def extract_phone_from_webhook
    # This will depend on the WhatsApp API provider format
    # Example for WhatsApp Business API format
    if params[:entry]&.first&.dig('changes')&.first&.dig('value', 'messages')&.first
      message_data = params[:entry].first['changes'].first['value']['messages'].first
      message_data['from']
    else
      params[:from] # Fallback for simpler formats
    end
  end

  def extract_content_from_webhook
    # This will depend on the WhatsApp API provider format
    if params[:entry]&.first&.dig('changes')&.first&.dig('value', 'messages')&.first
      message_data = params[:entry].first['changes'].first['value']['messages'].first
      message_data.dig('text', 'body') || message_data['text']
    else
      params[:text] || params[:content] # Fallback for simpler formats
    end
  end

  def should_send_confirmation?(result)
    # Send confirmation for successful presence confirmations/cancellations
    result.success? && result.data.is_a?(String) && 
      (result.data.include?('confirmed') || result.data.include?('cancelled') || result.data.include?('moved'))
  end

  def build_confirmation_message(result)
    "✅ #{result.data}"
  end

  def webhook_secret
    ENV['WHATSAPP_WEBHOOK_SECRET'] || 'development_secret'
  end

  def webhook_verify_token
    ENV['WHATSAPP_VERIFY_TOKEN'] || 'development_verify_token'
  end

  def json_request?
    request.content_type&.include?('application/json')
  end
end