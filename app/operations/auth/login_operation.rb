class Auth::LoginOperation < ApplicationOperation
  def call
    # Parse and validate parameters
    parse_and_validate_params!
    
    # Find user by email
    find_user!
    
    # Authenticate user credentials
    authenticate_user_credentials!
    
    # Validate user account status
    validate_user_account_status!
    
    # Generate authentication tokens
    generate_auth_tokens!
    
    # Log login event
    log_login_event!
    
    # Return success response
    prepare_success_response!
    
  rescue ValidationError => e
    handle_validation_error(e)
  rescue Auth::UserNotFound => e
    handle_user_not_found_error(e)
  rescue Auth::InvalidCredentials => e
    handle_invalid_credentials_error(e)
  rescue DatabaseError => e
    handle_database_error(e)
  rescue => e
    handle_unexpected_error(e)
  end

  private

  def parse_and_validate_params!
    @parsed_params = ParamsParserService.parse_login_params(params)
    
    # Validate required fields
    validate_required_fields!
    
    # Validate parameter formats
    validate_email_format!
    validate_password_presence!
  end

  def validate_required_fields!
    if @parsed_params[:email].blank?
      raise ValidationError, 'Email is required'
    end
    
    if @parsed_params[:password].blank?
      raise ValidationError, 'Password is required'
    end
  end

  def validate_email_format!
    email = @parsed_params[:email]
    unless email =~ URI::MailTo::EMAIL_REGEXP
      raise ValidationError, 'Email format is invalid'
    end
  end

  def validate_password_presence!
    password = @parsed_params[:password]
    if password.length < 1
      raise ValidationError, 'Password cannot be empty'
    end
  end

  def find_user!
    @user = User.find_by(email: @parsed_params[:email])
    unless @user
      raise Auth::UserNotFound, 'No account found with this email address'
    end
  rescue => e
    Rails.logger.error "Database error during user lookup: #{e.message}"
    raise DatabaseError, 'Database error during login'
  end

  def authenticate_user_credentials!
    unless @user.authenticate(@parsed_params[:password])
      # Add small delay to prevent timing attacks
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
    
    # Additional account status checks could go here
    # e.g., email verified, not suspended, etc.
  end

  def generate_auth_tokens!
    @token = JwtService.generate_user_token(@user)
    @expires_in = JwtService::TOKEN_LIFETIME.to_i
  rescue => e
    Rails.logger.error "Token generation failed for user #{@user.email}: #{e.message}"
    raise DatabaseError, "Failed to generate authentication token"
  end

  def log_login_event!
    Rails.logger.info "User login successful: #{@user.email} (#{@user.nickname})"
    # Could add audit logging here if needed
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

  # Error handlers
  def handle_validation_error(error)
    Rails.logger.warn "Login validation failed: #{error.message}"
    error_response(error.message, 'ValidationError')
  end

  def handle_user_not_found_error(error)
    Rails.logger.warn "Login failed - user not found: #{@parsed_params[:email]}"
    # Use generic message to prevent email enumeration
    error_response('Invalid email or password', 'InvalidCredentials')
  end

  def handle_invalid_credentials_error(error)
    Rails.logger.warn "Login failed - invalid credentials: #{@user&.email || @parsed_params[:email]}"
    error_response(error.message, 'InvalidCredentials')
  end

  def handle_database_error(error)
    Rails.logger.error "Login database error: #{error.message}"
    error_response('Login service temporarily unavailable', 'DatabaseError')
  end

  def handle_unexpected_error(error)
    Rails.logger.error "Login unexpected error: #{error.message}\n#{error.backtrace.join("\n")}"
    error_response('An unexpected error occurred during login', 'UnexpectedError')
  end
end