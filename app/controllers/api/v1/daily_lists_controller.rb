class Api::V1::DailyListsController < ApplicationController
  before_action :authenticate_user!

  # GET /api/v1/daily-lists/dashboard
  def dashboard
    result = DailyList::GetCurrentListsOperation.call(user: current_user)

    if result[:meta][:success]
      render json: {
        data: {
          current_lists: result[:data][:current_lists],
          daily_stats: result[:data][:daily_stats],
          historical_summary: result[:data][:historical_summary]
        },
        meta: {
          success: true,
          timestamp: Time.current
        }
      }
    else
      render json: { 
        errors: [{ 
          detail: result[:meta][:message] 
        }] 
      }, status: 422
    end
  end

  private

  def authenticate_user!
    token = request.headers['Authorization']&.gsub('Bearer ', '')
    return render json: { errors: [{ detail: 'Token não fornecido' }] }, status: 401 unless token

    decoded_token = JwtService.decode(token)
    return render json: { errors: [{ detail: 'Token inválido' }] }, status: 401 unless decoded_token

    @current_user = User.find_by(id: decoded_token[:user_id])
    return render json: { errors: [{ detail: 'Usuário não encontrado' }] }, status: 401 unless @current_user
  end

  def current_user
    @current_user
  end
end