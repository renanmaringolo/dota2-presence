class Auth::LoginOperation < ApplicationOperation
  def call
    parse_and_validate_params!
    find_user!
    authenticate_user_credentials!
    validate_user_account_status!
    generate_auth_tokens!
    log_login_event!
    prepare_success_response!
    
  rescue Auth::InvalidCredentials => e
    handle_invalid_credentials_error(e)
  rescue => e
    handle_unexpected_error(e)
  end

  private

  def parse_and_validate_params!
    @parsed_params = {
      email: params[:email]&.to_s&.downcase&.strip,
      password: params[:password]&.to_s
    }
    
    validate_required_fields!
    validate_email_format!
    validate_password_presence!
  end

  def validate_required_fields!
    if @parsed_params[:email].blank?
      raise Auth::InvalidCredentials, 'Email is required'
    end
    
    if @parsed_params[:password].blank?
      raise Auth::InvalidCredentials, 'Password is required'
    end
  end

  def validate_email_format!
    email = @parsed_params[:email]
    unless email =~ URI::MailTo::EMAIL_REGEXP
      raise Auth::InvalidCredentials, 'Email format is invalid'
    end
  end

  def validate_password_presence!
    password = @parsed_params[:password]
    if password.length < 1
      raise Auth::InvalidCredentials, 'Password cannot be empty'
    end
  end

  def find_user!
    @user = User.find_by(email: @parsed_params[:email])
    unless @user
      raise Auth::InvalidCredentials, 'Invalid email or password'
    end
  rescue => e
    Rails.logger.error "Database error during user lookup: #{e.message}"
    raise Auth::InvalidCredentials, 'Login service temporarily unavailable'
  end

  def authenticate_user_credentials!
    unless @user.authenticate(@parsed_params[:password])
      sleep(0.1)
      raise Auth::InvalidCredentials, 'Invalid email or password'
    end
  rescue BCrypt::Errors::InvalidHash => e
    Rails.logger.error "Password hash error for user #{@user.email}: #{e.message}"
    raise Auth::InvalidCredentials, 'Authentication error'
  end

  def validate_user_account_status!
    unless @user.active?
      raise Auth::InvalidCredentials, 'Account has been deactivated. Please contact support.'
    end
  end

  def generate_auth_tokens!
    @token = JwtService.generate_user_token(@user)
    @expires_in = JwtService::TOKEN_LIFETIME.to_i
  rescue => e
    Rails.logger.error "Token generation failed for user #{@user.email}: #{e.message}"
    raise Auth::InvalidCredentials, "Failed to generate authentication token"
  end

  def log_login_event!
    Rails.logger.info "User login successful: #{@user.email} (#{@user.nickname})"
  end

  def prepare_success_response!
    success_response({
      user: user_attributes,
      token: @token,
      expires_in: @expires_in
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

  def handle_invalid_credentials_error(error)
    Rails.logger.warn "Login failed - invalid credentials: #{@user&.email || @parsed_params[:email]}"
    error_response(error.message, 'InvalidCredentials')
  end

  def handle_unexpected_error(error)
    Rails.logger.error "Login unexpected error: #{error.message}\n#{error.backtrace.join("\n")}"
    error_response('An unexpected error occurred during login', 'UnexpectedError')
  end
end
