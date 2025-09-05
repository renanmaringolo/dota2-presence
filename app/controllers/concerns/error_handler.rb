module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
  end

  private

  def handle_standard_error(exception)
    Rails.logger.error "StandardError: #{exception.message}\n#{exception.backtrace.join("\n")}"
    render_error('Internal server error', 500)
  end

  def handle_not_found(exception)
    Rails.logger.warn "NotFound: #{exception.message}"
    render_error('Record not found', 404)
  end

  def handle_validation_error(exception)
    Rails.logger.warn "ValidationError: #{exception.message}"
    errors = exception.record.errors.full_messages
    render_validation_errors(errors)
  end

  def render_error(message, status_code)
    render json: {
      errors: [{
        status: status_code.to_s,
        title: get_status_title(status_code),
        detail: message
      }]
    }, status: status_code
  end

  def render_validation_errors(errors)
    formatted_errors = errors.map do |error|
      {
        status: '422',
        title: 'Validation Error',
        detail: error
      }
    end

    render json: { errors: formatted_errors }, status: :unprocessable_content
  end

  def render_operation_error(operation_result)
    error_message = operation_result[:meta][:message] || 'Operation failed'
    error_type = operation_result[:meta][:error_type] || 'OperationError'
    
    status_code = case error_type
    when /NotFound/
      404
    when /Unauthorized/
      401
    when /Forbidden/
      403
    else
      422
    end

    render json: {
      errors: [{
        status: status_code.to_s,
        title: get_status_title(status_code),
        detail: error_message,
        code: error_type
      }]
    }, status: status_code
  end

  def get_status_title(status_code)
    case status_code
    when 400 then 'Bad Request'
    when 401 then 'Unauthorized'
    when 403 then 'Forbidden'
    when 404 then 'Not Found'
    when 422 then 'Unprocessable Entity'
    when 500 then 'Internal Server Error'
    else 'Error'
    end
  end
end
