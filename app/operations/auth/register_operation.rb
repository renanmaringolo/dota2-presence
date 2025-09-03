class Auth::RegisterOperation < ApplicationOperation
  def call
    # Parse and validate ALL parameters
    parse_and_validate_params!
    
    # Check ALL business rules and edge cases
    validate_all_business_rules!
    
    # Create user with full transaction safety
    create_user_with_transaction!
    
    # Generate authentication tokens
    generate_auth_tokens!
    
    # Log registration event
    log_registration_event!
    
    # Return success response
    prepare_success_response!
    
  rescue ValidationError => e
    handle_validation_error(e)
  rescue DuplicateUserError => e
    handle_duplicate_error(e)
  rescue DatabaseError => e
    handle_database_error(e)
  rescue => e
    handle_unexpected_error(e)
  end

  private

  def parse_and_validate_params!
    @parsed_params = ParamsParserService.parse_registration_params(params)
    
    # Validate required fields
    validate_required_fields!
    
    # Validate formats and constraints
    validate_email_format!
    validate_password_strength!
    validate_nickname_format!
    validate_phone_format!
    validate_rank_combination!
    validate_positions_array!
  end

  def validate_required_fields!
    required_fields = [:email, :password, :name, :nickname, :rank_medal, :rank_stars]
    required_fields.each do |field|
      if @parsed_params[field].blank?
        raise ValidationError, "#{field.to_s.humanize} is required"
      end
    end
  end

  def validate_email_format!
    email = @parsed_params[:email]
    unless email =~ URI::MailTo::EMAIL_REGEXP
      raise ValidationError, 'Email format is invalid'
    end
  end

  def validate_password_strength!
    password = @parsed_params[:password]
    if password.length < 6
      raise ValidationError, 'Password must be at least 6 characters long'
    end
  end

  def validate_nickname_format!
    nickname = @parsed_params[:nickname]
    if nickname.length < 2
      raise ValidationError, 'Nickname must be at least 2 characters long'
    end
    if nickname.length > 20
      raise ValidationError, 'Nickname cannot be longer than 20 characters'
    end
    unless nickname =~ /\A[a-zA-Z0-9_-]+\z/
      raise ValidationError, 'Nickname can only contain letters, numbers, underscores and hyphens'
    end
  end

  def validate_phone_format!
    phone = @parsed_params[:phone]
    return if phone.blank? # Phone is optional
    
    unless phone =~ /\A\d{10,11}\z/
      raise ValidationError, 'Phone number must have 10 or 11 digits'
    end
  end

  def validate_rank_combination!
    medal = @parsed_params[:rank_medal]
    stars = @parsed_params[:rank_stars]
    
    unless User::MEDALS.include?(medal)
      raise ValidationError, "Invalid rank medal. Must be one of: #{User::MEDALS.join(', ')}"
    end
    
    if medal == 'immortal'
      unless stars.is_a?(Integer) && stars > 0
        raise ValidationError, 'Immortal rank must have a positive number for MMR ranking'
      end
    else
      unless stars.is_a?(Integer) && stars.in?(1..5)
        raise ValidationError, 'Rank stars must be between 1 and 5'
      end
    end
  end

  def validate_positions_array!
    positions = @parsed_params[:positions]
    return if positions.empty? # Positions are optional
    
    invalid_positions = positions - User::POSITIONS
    unless invalid_positions.empty?
      raise ValidationError, "Invalid positions: #{invalid_positions.join(', ')}. Valid positions: #{User::POSITIONS.join(', ')}"
    end
  end

  def validate_all_business_rules!
    check_email_availability!
    check_name_phone_combination!
    check_phone_availability! if @parsed_params[:phone].present?
  end

  def check_email_availability!
    if User.exists?(email: @parsed_params[:email])
      raise DuplicateUserError, 'Email is already registered'
    end
  end

  def check_name_phone_combination!
    if User.exists?(name: @parsed_params[:name], phone: @parsed_params[:phone])
      raise DuplicateUserError, 'Name and phone combination already exists'
    end
  end

  def check_phone_availability!
    if User.exists?(phone: @parsed_params[:phone])
      raise DuplicateUserError, 'Phone number is already registered'
    end
  end

  def create_user_with_transaction!
    ActiveRecord::Base.transaction do
      @user = User.create!(@parsed_params)
      Rails.logger.info "User created successfully: #{@user.id} (#{@user.email})"
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "User creation failed: #{e.message}"
    raise DatabaseError, "Failed to create user: #{e.record.errors.full_messages.join(', ')}"
  rescue => e
    Rails.logger.error "Database transaction failed: #{e.message}"
    raise DatabaseError, "Database error during user creation"
  end

  def generate_auth_tokens!
    @token = JwtService.generate_user_token(@user)
    @expires_in = JwtService::TOKEN_LIFETIME.to_i
  rescue => e
    Rails.logger.error "Token generation failed: #{e.message}"
    raise DatabaseError, "Failed to generate authentication token"
  end

  def log_registration_event!
    Rails.logger.info "User registration completed: #{@user.email} (#{@user.nickname})"
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
      role: @user.role
    }
  end

  # Error handlers
  def handle_validation_error(error)
    Rails.logger.warn "Registration validation failed: #{error.message}"
    error_response(error.message, 'ValidationError')
  end

  def handle_duplicate_error(error)
    Rails.logger.warn "Registration duplicate error: #{error.message}"
    error_response(error.message, 'DuplicateUserError')
  end

  def handle_database_error(error)
    Rails.logger.error "Registration database error: #{error.message}"
    error_response(error.message, 'DatabaseError')
  end

  def handle_unexpected_error(error)
    Rails.logger.error "Registration unexpected error: #{error.message}\n#{error.backtrace.join("\n")}"
    error_response('An unexpected error occurred during registration', 'UnexpectedError')
  end
end