class DailyListResource < ApplicationResource
  type :daily_lists
  model DailyList

  # Attributes
  attribute :id, :string, only: [:readable]
  attribute :date, :date, only: [:readable] 
  attribute :list_type, :string, only: [:readable]
  attribute :sequence_number, :integer, only: [:readable]
  attribute :display_name, :string, only: [:readable]
  attribute :status, :string, only: [:readable]
  attribute :max_players, :integer, only: [:readable]
  attribute :available_positions, :array_of_strings, only: [:readable]
  attribute :created_by, :string, only: [:readable]

  # Custom attributes
  extra_attribute :confirmed_players, :array, readable: true do
    @object.presences.confirmed.includes(:user).map do |presence|
      {
        position: presence.position,
        user: {
          id: presence.user.id,
          nickname: presence.user.nickname,
          rank: presence.user.display_rank
        }
      }
    end
  end

  extra_attribute :user_status, :hash, readable: true do
    # This will be populated by the operation
    @user_status || {}
  end

  def user_status=(value)
    @user_status = value
  end
end