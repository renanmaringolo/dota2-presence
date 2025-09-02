class JwtService
  SECRET_KEY = Rails.application.secret_key_base
  TOKEN_LIFETIME = 24.hours

  def self.encode(payload, exp = TOKEN_LIFETIME.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError, JWT::ExpiredSignature => e
    Rails.logger.error "JWT Error: #{e.message}"
    nil
  end

  def self.generate_user_token(user)
    encode({
      user_id: user.id,
      email: user.email,
      nickname: user.nickname,
      role: user.role,
      type: 'user'
    })
  end

  def self.valid_user_token?(token)
    decoded = decode(token)
    decoded && decoded[:type] == 'user'
  end
end