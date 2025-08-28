module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:show, :update, :destroy]

    def index
      users = User.includes(:presences)
                  .order(:category, :name)

      if params[:category].present?
        users = users.where(category: params[:category])
      end

      if params[:active].present?
        users = users.where(active: params[:active] == 'true')
      end

      render_success({
        users: users.map(&method(:user_json)),
        total: users.count
      })
    end

    def show
      render_success(user_json(@user))
    end

    def create
      user = User.new(user_params)
      
      if user.save
        render_success(user_json(user), 'User created successfully')
      else
        render_error(user.errors.full_messages.join(', '))
      end
    end

    def update
      if @user.update(user_params)
        render_success(user_json(@user), 'User updated successfully')
      else
        render_error(@user.errors.full_messages.join(', '))
      end
    end

    def destroy
      @user.update!(active: false)
      render_success(nil, 'User deactivated successfully')
    end

    private

    def set_user
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_error('User not found', :not_found)
    end

    def user_params
      params.require(:user).permit(:name, :nickname, :phone, :category, :preferred_position, :active, positions: [])
    end

    def user_json(user)
      {
        id: user.id,
        name: user.name,
        nickname: user.nickname,
        phone: user.phone,
        category: user.category,
        positions: user.positions,
        preferred_position: user.preferred_position,
        active: user.active,
        full_display_name: user.full_display_name,
        recent_presences_count: user.presences.where('created_at > ?', 7.days.ago).count,
        created_at: user.created_at,
        updated_at: user.updated_at
      }
    end
  end
end