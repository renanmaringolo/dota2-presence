class Api::V1::AuthController < ApplicationController
  def register
    if params[:email] && params[:name]
      permitted_attributes = params.permit(:name, :email, :password, :nickname, :phone, :category, :rank_medal,
                                           :rank_stars, :preferred_position, positions: []).to_h
    else
      attributes = params.dig(:data, :attributes) || {}
      permitted_attributes = attributes.is_a?(ActionController::Parameters) ? attributes.permit!.to_h : attributes
    end

    operation_result = Auth::RegisterOperation.call(permitted_attributes)

    if operation_result[:meta][:success]
      user = User.find(operation_result[:data][:user][:id])

      auth_meta = {
        token: operation_result[:data][:token],
        expires_in: operation_result[:data][:expires_in]
      }

      render json: {
        data: {
          id: user.id.to_s,
          type: 'users',
          attributes: {
            id: user.id,
            email: user.email,
            name: user.name,
            nickname: user.nickname,
            phone: user.phone,
            category: user.category,
            rank_medal: user.rank_medal,
            rank_stars: user.rank_stars,
            preferred_position: user.preferred_position,
            positions: user.positions,
            role: user.role,
            active: user.active,
            display_rank: user.display_rank,
            full_display_name: user.full_display_name,
            can_join_immortal_list: user.can_join_immortal_list?
          }
        },
        meta: auth_meta
      }, status: :created
    else
      error_message = operation_result[:meta][:message]
      error_type = operation_result[:meta][:error_type]

      render json: {
        errors: [{
          status: '422',
          title: error_type || 'Registration Error',
          detail: error_message
        }]
      }, status: :unprocessable_content
    end
  end

  def login
    if params[:email] && params[:password]
      permitted_attributes = { email: params[:email], password: params[:password] }
    else
      attributes = params.dig(:data, :attributes) || {}
      permitted_attributes = attributes.is_a?(ActionController::Parameters) ? attributes.permit!.to_h : attributes
    end

    operation_result = Auth::LoginOperation.call(permitted_attributes)

    if operation_result[:meta][:success]
      user_data = operation_result[:data][:user]
      auth_meta = {
        token: operation_result[:data][:token],
        expires_in: operation_result[:data][:expires_in]
      }

      render json: {
        data: {
          id: user_data[:id].to_s,
          type: 'users',
          attributes: user_data
        },
        meta: auth_meta
      }, status: :ok
    else
      error_message = operation_result[:meta][:message]
      error_type = operation_result[:meta][:error_type]

      render json: {
        errors: [{
          status: '401',
          title: error_type || 'Login Error',
          detail: error_message
        }]
      }, status: :unauthorized
    end
  end

  def me
    token = request.headers['Authorization']&.gsub('Bearer ', '')
    operation_result = Auth::MeOperation.call(token: token)

    if operation_result[:meta][:success]
      user_data = operation_result[:data][:user]
      auth_meta = {
        token: operation_result[:data][:token],
        expires_in: operation_result[:data][:expires_in]
      }

      render json: {
        data: {
          id: user_data[:id].to_s,
          type: 'users',
          attributes: user_data
        },
        meta: auth_meta
      }, status: :ok
    else
      error_message = operation_result[:meta][:message]
      error_type = operation_result[:meta][:error_type]

      render json: {
        errors: [{
          status: '401',
          title: error_type || 'Authentication Error',
          detail: error_message
        }]
      }, status: :unauthorized
    end
  end
end
