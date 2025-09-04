class Api::V1::PresencesController < ApplicationController
  before_action :authenticate_user!

  # POST /api/v1/presences
  def create
    operation_result = Presence::ConfirmOperation.call(
      user: current_user,
      position: presence_params[:position],
      list_type: presence_params[:list_type]
    )

    if operation_result[:meta][:success]
      # Return simplified JSON response
      render json: {
        data: {
          presence: operation_result[:data][:presence],
          updated_list: operation_result[:data][:updated_list],
          next_list_created: operation_result[:data][:next_list_created],
          next_list: operation_result[:data][:next_list]
        },
        meta: {
          success: true,
          message: build_success_message(operation_result[:data])
        }
      }, status: :created
    else
      error_type = operation_result[:meta][:error_type] || 'PresenceError'
      error_message = operation_result[:meta][:message]
      
      render json: {
        errors: [{
          status: '422',
          title: error_type,
          detail: error_message
        }]
      }, status: :unprocessable_content
    end
  end

  # DELETE /api/v1/presences/:list_type
  def destroy
    presence = find_user_presence_for_list_type(params[:list_type])
    
    unless presence
      return render json: {
        errors: [{
          status: '404',
          title: 'NotFound',
          detail: 'Presença não encontrada para cancelar'
        }]
      }, status: :not_found
    end

    if presence.status == 'cancelled'
      return render json: {
        errors: [{
          status: '422',
          title: 'AlreadyCancelled',
          detail: 'Presença já foi cancelada anteriormente'
        }]
      }, status: :unprocessable_content
    end

    begin
      presence.toggle_to_cancelled!("Cancelado pelo usuário")
      
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
      }, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render json: {
        errors: [{
          status: '422',
          title: 'ValidationError',
          detail: "Erro ao cancelar presença: #{e.message}"
        }]
      }, status: :unprocessable_content
    end
  end

  private

  def presence_params
    # Handle both direct params and nested Graphiti format
    if params[:list_type] && params[:position]
      # Direct format from curl
      params.permit(:position, :list_type)
    else
      # Graphiti nested format
      params.require(:data).require(:attributes).permit(:position, :list_type)
    end
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
             .first&.presences&.find_by(user: current_user, status: 'confirmed')
  end
end