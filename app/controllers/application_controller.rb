class ApplicationController < ActionController::API
  include ErrorHandler
  include Graphiti::Rails::Responders

  before_action :set_cors_headers

  def show_detailed_exceptions?
    Rails.env.local?
  end

  protected

  def call_operation(operation_class, **params)
    result = operation_class.call(**params)
    if block_given?
      yield(result)
    else
      result
    end
  rescue StandardError => e
    handle_exception(e)
  end

  def authenticate_user!
    token = request.headers['Authorization']&.gsub('Bearer ', '')

    unless token
      render json: {
        errors: [{
          status: '401',
          title: 'Authentication Required',
          detail: 'Authentication token required'
        }]
      }, status: :unauthorized
      return
    end

    operation_result = Auth::MeOperation.call(token: token)

    if operation_result[:meta][:success]
      @current_user = operation_result[:data][:user_object]
    else
      render json: {
        errors: [{
          status: '401',
          title: 'Invalid Token',
          detail: 'Invalid token'
        }]
      }, status: :unauthorized
    end
  end

  attr_reader :current_user

  private

  def set_cors_headers
    origin = request.headers['Origin']
    allowed_origins = ENV.fetch('CORS_ORIGINS', 'http://localhost:3000,http://localhost:3001,http://localhost:3002,http://localhost:3003').split(',')

    if allowed_origins.include?(origin)
      response.headers['Access-Control-Allow-Origin'] = origin
      response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, PATCH, DELETE, OPTIONS'
      response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, X-Requested-With'
      response.headers['Access-Control-Max-Age'] = '1728000'
    end

    return unless request.method == 'OPTIONS'

    render json: {}, status: :ok
  end
end
