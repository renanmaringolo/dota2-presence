class PresencesController < ApplicationController
  def index
    daily_list = DailyList.find_by(date: Date.current)
    
    unless daily_list
      return render_error('No daily list available for today', :not_found)
    end

    render_success({
      daily_list: {
        id: daily_list.id,
        date: daily_list.date,
        status: daily_list.status
      },
      presences: daily_list.presences.confirmed.includes(:user).map do |presence|
        {
          user: {
            nickname: presence.user.nickname,
            category: presence.user.category
          },
          position: presence.position,
          confirmed_at: presence.confirmed_at
        }
      end,
      available_positions: available_positions(daily_list),
      summary: daily_list.summary
    })
  end

  def create
    daily_list = DailyList.find_by(date: Date.current)
    
    unless daily_list
      return render_error('No daily list available for today', :not_found)
    end

    user = User.active.find_by("LOWER(nickname) = ?", params[:nickname].to_s.downcase)
    unless user
      return render_error('User not found or inactive', :not_found)
    end

    position = params[:position].to_s.upcase
    unless user.plays_position?(position)
      return render_error("User #{user.nickname} does not play position #{position}")
    end

    # Check if position is already taken
    if daily_list.presences.exists?(position: position)
      return render_error("Position #{position} is already taken")
    end

    # Check if user already has a presence for today
    existing_presence = daily_list.presences.find_by(user: user)
    if existing_presence
      # Update existing presence
      if existing_presence.update(presence_params.merge(position: position, confirmed_at: Time.current))
        render_success({
          id: existing_presence.id,
          message: "#{user.nickname} moved to #{position}"
        })
      else
        render_error(existing_presence.errors.full_messages.join(', '))
      end
    else
      # Create new presence
      presence = daily_list.presences.build(presence_params)
      presence.user = user
      presence.position = position
      presence.source = 'web'
      presence.status = 'confirmed'
      presence.confirmed_at = Time.current

      if presence.save
        render_success({
          id: presence.id,
          message: "#{user.nickname} confirmed for #{position}"
        })
      else
        render_error(presence.errors.full_messages.join(', '))
      end
    end
  end

  def destroy
    daily_list = DailyList.find_by(date: Date.current)
    
    unless daily_list
      return render_error('No daily list available for today', :not_found)
    end

    user = User.active.find_by("LOWER(nickname) = ?", params[:nickname].to_s.downcase)
    unless user
      return render_error('User not found or inactive', :not_found)
    end

    presence = daily_list.presences.find_by(user: user)
    unless presence
      return render_error("#{user.nickname} was not confirmed for today")
    end

    if presence.destroy
      render_success(nil, "#{user.nickname} presence cancelled")
    else
      render_error('Failed to cancel presence')
    end
  end

  private

  def presence_params
    params.permit(:notes)
  end

  def available_positions(daily_list)
    taken_positions = daily_list.presences.confirmed.pluck(:position)
    DailyList::POSITIONS - taken_positions
  end
end