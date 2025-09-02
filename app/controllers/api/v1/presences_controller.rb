class Api::V1::PresencesController < ApplicationController
  before_action :authenticate_user!

  # POST /api/v1/presences
  def create
    result = Presence::ConfirmOperation.call(
      user: current_user,
      position: presence_params[:position],
      list_type: presence_params[:list_type]
    )

    if result[:meta][:success]
      render json: {
        data: {
          id: result[:data][:presence][:id].to_s,
          type: 'presence',
          attributes: result[:data][:presence]
        },
        meta: {
          success: true,
          updated_list: result[:data][:updated_list],
          next_list_created: result[:data][:next_list_created],
          next_list: result[:data][:next_list],
          message: build_success_message(result[:data])
        }
      }, status: 201
    else
      render json: { 
        errors: [{ 
          detail: result[:meta][:message],
          code: result[:meta][:error_type]
        }] 
      }, status: 422
    end
  end

  # DELETE /api/v1/presences/:list_type
  def destroy
    # Buscar presença do usuário para o tipo de lista
    presence = find_user_presence_for_list_type(params[:list_type])
    
    unless presence
      return render json: { 
        errors: [{ detail: 'Presença não encontrada para cancelar' }] 
      }, status: 404
    end

    if presence.update(status: 'cancelled', notes: "Cancelado pelo usuário em #{Time.current}")
      # Se a lista estava cheia, voltar para 'open'
      daily_list = presence.daily_list
      if daily_list.status == 'full'
        daily_list.update!(status: 'open')
      end

      render json: {
        data: nil,
        meta: {
          success: true,
          message: "Presença cancelada com sucesso!"
        }
      }
    else
      render json: { 
        errors: [{ detail: 'Erro ao cancelar presença' }] 
      }, status: 422
    end
  end

  private

  def presence_params
    params.require(:data).require(:attributes).permit(:position, :list_type)
  end

  def build_success_message(data)
    message = "Presença confirmada na posição #{data[:presence][:position]}!"

    if data[:next_list_created]
      message += " Lista ficou cheia, #{data[:next_list][:display_name]} foi criada automaticamente."
    end

    message
  end

  def find_user_presence_for_list_type(list_type)
    DailyList.for_date(Date.current)
             .for_type(list_type)
             .joins(:presences)
             .where(presences: { user: current_user, status: 'confirmed' })
             .first&.presences&.find_by(user: current_user)
  end

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