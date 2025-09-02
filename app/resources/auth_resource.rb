class AuthResource < ApplicationResource
  # Login attributes (no model association)
  attribute :email, :string
  attribute :password, :string
  
  # User attributes for response
  attribute :id, :integer, readable: true, writable: false
  attribute :name, :string, readable: true, writable: false
  attribute :nickname, :string, readable: true, writable: false
  attribute :category, :string, readable: true, writable: false
  attribute :rank_medal, :string, readable: true, writable: false
  attribute :rank_stars, :integer, readable: true, writable: false
  attribute :role, :string, readable: true, writable: false

  # No model association for auth resource
  
  # Secondary endpoints for auth operations (paths without namespace prefix)
  secondary_endpoint '/auth/login', [:create]
  secondary_endpoint '/auth/me', [:show]
  
  # Authentication method - Bridge to Operation (ZERO business logic)
  def authenticate
    @operation_result = Auth::LoginOperation.call(raw_attributes)
    
    if @operation_result[:meta][:success]
      # Create mock object with user data for Graphiti serialization
      user_data = @operation_result[:data][:user]
      @model = OpenStruct.new(user_data)
      true
    else
      convert_operation_errors_to_graphiti
      false
    end
  end

  # Auth meta for token response
  def auth_meta
    return {} unless @operation_result&.dig(:meta, :success)
    
    {
      token: @operation_result[:data][:token],
      expires_in: @operation_result[:data][:expires_in]
    }
  end

  private

  # Convert Operation errors to Graphiti format (NO business logic)
  def convert_operation_errors_to_graphiti
    @model = OpenStruct.new(email: raw_attributes[:email])  # Mock for errors
    
    error_message = @operation_result[:meta][:message]
    error_type = @operation_result[:meta][:error_type]
    
    # Create ActiveModel-like errors object
    @model.extend(ActiveModel::Validations)
    
    case error_type
    when 'ValidationError'
      add_validation_error_to_model(error_message)
    when 'InvalidCredentials'
      @model.errors.add(:base, error_message)
    else
      @model.errors.add(:base, error_message)
    end
  end

  def add_validation_error_to_model(message)
    case message
    when /email/i
      @model.errors.add(:email, message)
    when /password/i
      @model.errors.add(:password, message)
    else
      @model.errors.add(:base, message)
    end
  end
end