class ApplicationController < ActionController::API
  include ErrorHandler
  include Graphiti::Rails::Responders

  before_action :set_cors_headers

  def show_detailed_exceptions?
    Rails.env.development? || Rails.env.test?
  end

  protected

  def authenticate_user!
    token = request.headers['Authorization']&.gsub('Bearer ', '')
    
    unless token
      render json: {
        errors: [{
          status: '401',
          title: 'Authentication Required',
          detail: 'Token de autenticação necessário'
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
          detail: 'Token inválido'
        }]
      }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

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
    
    if request.method == 'OPTIONS'
      render json: {}, status: :ok
    end
  end
end
