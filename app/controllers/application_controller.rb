class ApplicationController < ActionController::API
  private

  def render_json_response(success, data = nil, message = nil, status = :ok)
    render json: {
      success: success,
      data: data,
      message: message,
      timestamp: Time.current.iso8601
    }, status: status
  end

  def render_error(message, status = :unprocessable_entity)
    render_json_response(false, nil, message, status)
  end

  def render_success(data = nil, message = nil)
    render_json_response(true, data, message, :ok)
  end
end
