class PresenceResource < ApplicationResource
  type :presences
  model Presence

  # Attributes
  attribute :id, :string, only: [:readable]
  attribute :position, :string, only: [:readable, :writable]
  attribute :source, :string, only: [:readable]
  attribute :status, :string, only: [:readable]
  attribute :confirmed_at, :datetime, only: [:readable]
  attribute :notes, :string, only: [:readable]

  # Relationships
  belongs_to :user
  belongs_to :daily_list

  # Custom attributes
  extra_attribute :user_info, :hash, readable: true do
    if @object.user
      {
        id: @object.user.id,
        nickname: @object.user.nickname,
        rank: @object.user.display_rank
      }
    end
  end

  extra_attribute :daily_list_info, :hash, readable: true do
    if @object.daily_list
      {
        id: @object.daily_list.id,
        display_name: @object.daily_list.display_name,
        date: @object.daily_list.date,
        list_type: @object.daily_list.list_type
      }
    end
  end
end