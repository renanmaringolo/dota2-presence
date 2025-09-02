class UserResource < ApplicationResource
  # Serialization attributes only
  attribute :id, :integer, readable: true, writable: false
  attribute :email, :string, readable: true, writable: true
  attribute :name, :string, readable: true, writable: true
  attribute :nickname, :string, readable: true, writable: true
  attribute :phone, :string, readable: true, writable: true
  attribute :category, :string, readable: true, writable: false
  attribute :rank_medal, :string, readable: true, writable: true
  attribute :rank_stars, :integer, readable: true, writable: true
  attribute :preferred_position, :string, readable: true, writable: true
  attribute :positions, :array_of_strings, readable: true, writable: true
  attribute :role, :string, readable: true, writable: true
  attribute :active, :boolean, readable: true, writable: true
  attribute :created_at, :datetime, readable: true, writable: false
  attribute :updated_at, :datetime, readable: true, writable: false
  
  # Computed attributes
  attribute :display_rank, :string, readable: true, writable: false do
    @object.display_rank
  end
  
  attribute :full_display_name, :string, readable: true, writable: false do
    @object.full_display_name
  end
  
  attribute :can_join_immortal_list, :boolean, readable: true, writable: false do
    @object.can_join_immortal_list?
  end

  # Model association
  self.model = User
  
  # Secondary endpoint for auth registration (path without namespace prefix)
  secondary_endpoint '/auth/register', [:create]

  # Filters
  filter :email, :string
  filter :nickname, :string
  filter :category, :string
  filter :role, :string
  filter :active, :boolean

  # Sorting
  sort :created_at, :updated_at, :nickname, :name

  # Custom save method - Bridge to Operation (ZERO business logic)
  def save
    @operation_result = Auth::RegisterOperation.call(raw_attributes)
    
    if @operation_result[:meta][:success]
      @model = User.find(@operation_result[:data][:user][:id])
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
    @model = User.new  # Mock model for Graphiti error handling
    error_message = @operation_result[:meta][:message]
    error_type = @operation_result[:meta][:error_type]
    
    # Map error types to appropriate field errors
    case error_type
    when 'ValidationError'
      add_validation_error_to_model(error_message)
    when 'DuplicateUserError'
      add_duplicate_error_to_model(error_message)
    else
      @model.errors.add(:base, error_message)
    end
  end

  def add_validation_error_to_model(message)
    # Map specific validation messages to fields
    case message
    when /email/i
      @model.errors.add(:email, message)
    when /password/i
      @model.errors.add(:password, message)
    when /nickname/i
      @model.errors.add(:nickname, message)
    when /phone/i
      @model.errors.add(:phone, message)
    when /rank/i
      @model.errors.add(:rank_medal, message)
    else
      @model.errors.add(:base, message)
    end
  end

  def add_duplicate_error_to_model(message)
    case message
    when /email/i
      @model.errors.add(:email, message)
    when /nickname/i
      @model.errors.add(:nickname, message)
    when /phone/i
      @model.errors.add(:phone, message)
    else
      @model.errors.add(:base, message)
    end
  end
end