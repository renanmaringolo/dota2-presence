class Api::V1::DailyListsController < ApplicationController
  before_action :authenticate_user!

  # GET /api/v1/daily-lists/dashboard
  def dashboard
    operation_result = DailyList::GetCurrentListsOperation.call(user: current_user)

    if operation_result[:meta][:success]
      # Return current lists as they come from the operation (already serialized)
      current_lists = operation_result[:data][:current_lists]

      render json: {
        data: {
          current_lists: current_lists,
          daily_stats: operation_result[:data][:daily_stats],
          historical_summary: operation_result[:data][:historical_summary]
        },
        meta: {
          success: true,
          timestamp: Time.current
        }
      }
    else
      error_type = operation_result[:meta][:error_type] || 'DashboardError'
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
end
