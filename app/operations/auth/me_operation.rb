class Auth::MeOperation < ApplicationOperation
  def call
    extract_and_validate_token!
    find_user_from_token!
    validate_user_account_status!
    log_me_event!
    prepare_success_response!
    
  rescue TokenError => e
    handle_token_error(e)
  rescue Auth::UserNotFound => e
    handle_user_not_found_error(e)
  rescue DatabaseError => e
    handle_database_error(e)
  rescue => e
    handle_unexpected_error(e)
  end

  private

  def extract_and_validate_token!
    @token = params[:token]
    
    unless @token
      raise TokenError, 'Authorization token is required'
    end
    
    @token = @token.gsub('Bearer ', '') if @token.start_with?('Bearer ')
    
    @decoded_token = JwtService.decode(@token)
    unless @decoded_token
      raise TokenError, 'Invalid or expired token'
    end
    
    unless JwtService.valid_user_token?(@token)
      raise TokenError, 'Invalid token type'
    end
  end

  def find_user_from_token!
    user_id = @decoded_token[:user_id]
    unless user_id
      raise TokenError, 'Token missing user information'
    end
    
    @user = User.find(user_id)
  rescue ActiveRecord::RecordNotFound
    raise Auth::UserNotFound, 'User not found for this token'
  rescue => e
    Rails.logger.error "Database error during user lookup: #{e.message}"
    raise DatabaseError, 'Database error during authentication'
  end

  def validate_user_account_status!
    unless @user.active?
      raise TokenError, 'Account has been deactivated. Please contact support.'
    end
  end

  def log_me_event!
    Rails.logger.info "User me request: #{@user.email} (#{@user.nickname})"
  end

  def prepare_success_response!
    token_exp = @decoded_token[:exp]
    current_time = Time.current.to_i
    expires_in = token_exp - current_time
    
    success_response({
      user: user_attributes,
      user_object: @user,
      token: @token,
      expires_in: expires_in
    })
  end

  def user_attributes
    {
      id: @user.id,
      email: @user.email,
      name: @user.name,
      nickname: @user.nickname,
      phone: @user.phone,
      category: @user.category,
      rank_medal: @user.rank_medal,
      rank_stars: @user.rank_stars,
      preferred_position: @user.preferred_position,
      positions: @user.positions,
      role: @user.role,
      active: @user.active,
      display_rank: @user.display_rank,
      full_display_name: @user.full_display_name,
      can_join_immortal_list: @user.can_join_immortal_list?
    }
  end

  def handle_token_error(error)
    Rails.logger.warn "Me token error: #{error.message}"
    error_response(error.message, 'TokenError')
  end

  def handle_user_not_found_error(error)
    Rails.logger.warn "Me user not found: #{error.message}"
    error_response('Invalid or expired token', 'TokenError')
  end

  def handle_database_error(error)
    Rails.logger.error "Me database error: #{error.message}"
    error_response('Authentication service temporarily unavailable', 'DatabaseError')
  end

  def handle_unexpected_error(error)
    Rails.logger.error "Me unexpected error: #{error.message}\n#{error.backtrace.join("\n")}"
    error_response('An unexpected error occurred during authentication', 'UnexpectedError')
  end
end
