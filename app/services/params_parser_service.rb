class ParamsParserService
  def self.parse_registration_params(raw_params)
    {
      email: normalize_email(raw_params[:email]),
      password: raw_params[:password]&.to_s,
      name: normalize_name(raw_params[:name]),
      nickname: normalize_nickname(raw_params[:nickname]),
      phone: normalize_phone(raw_params[:phone]),
      rank_medal: normalize_rank_medal(raw_params[:rank_medal]),
      rank_stars: parse_rank_stars(raw_params[:rank_stars]),
      preferred_position: normalize_position(raw_params[:preferred_position]),
      positions: parse_positions_array(raw_params[:positions]),
      category: raw_params[:category],
      role: raw_params[:role] || 'player'
    }
  end

  def self.parse_login_params(raw_params)
    {
      email: normalize_email(raw_params[:email]),
      password: raw_params[:password]&.to_s
    }
  end

  private

  def self.normalize_email(email)
    return nil if email.blank?
    email.to_s.downcase.strip
  end

  def self.normalize_name(name)
    return nil if name.blank?
    name.to_s.strip.titleize
  end

  def self.normalize_nickname(nickname)
    return nil if nickname.blank?
    nickname.to_s.strip
  end

  def self.normalize_phone(phone)
    return nil if phone.blank?
    phone.to_s.gsub(/\D/, '')
  end

  def self.normalize_rank_medal(rank_medal)
    return nil if rank_medal.blank?
    rank_medal.to_s.downcase.strip
  end

  def self.parse_rank_stars(rank_stars)
    return nil if rank_stars.blank?
    rank_stars.to_i
  end

  def self.normalize_position(position)
    return nil if position.blank?
    position.to_s.upcase.strip
  end

  def self.parse_positions_array(positions)
    return [] if positions.blank?
    
    case positions
    when Array
      positions.map { |pos| normalize_position(pos) }.compact
    when String
      begin
        JSON.parse(positions).map { |pos| normalize_position(pos) }.compact
      rescue JSON::ParserError
        []
      end
    else
      []
    end
  end
end
