class AuthResource < ApplicationResource
  attribute :email, :string
  attribute :password, :string
  attribute :id, :integer, readable: true, writable: false
  attribute :name, :string, readable: true, writable: false
  attribute :nickname, :string, readable: true, writable: false
  attribute :category, :string, readable: true, writable: false
  attribute :rank_medal, :string, readable: true, writable: false
  attribute :rank_stars, :integer, readable: true, writable: false
  attribute :role, :string, readable: true, writable: false

  secondary_endpoint '/auth/login', [:create]
  secondary_endpoint '/auth/me', [:show]
  
  def authenticate
    @operation_result = Auth::LoginOperation.call(raw_attributes)
    
    if @operation_result[:meta][:success]
      user_data = @operation_result[:data][:user]
      @model = OpenStruct.new(user_data)
      true
    else
      convert_operation_errors_to_graphiti
      false
    end
  end

  def auth_meta
    return {} unless @operation_result&.dig(:meta, :success)
    
    {
      token: @operation_result[:data][:token],
      expires_in: @operation_result[:data][:expires_in]
    }
  end

  private

  def convert_operation_errors_to_graphiti
    @model = OpenStruct.new(email: raw_attributes[:email])
    
    error_message = @operation_result[:meta][:message]
    error_type = @operation_result[:meta][:error_type]
    
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
