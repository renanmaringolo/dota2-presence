class ApplicationController < ActionController::API
  include ErrorHandler
  include Graphiti::Rails::Responders

  before_action :set_cors_headers

  # Required for Graphiti
  def show_detailed_exceptions?
    Rails.env.development? || Rails.env.test?
  end

  private

  def set_cors_headers
    origin = request.headers['Origin']
    allowed_origins = ['http://localhost:3000', 'http://localhost:3001', 'http://localhost:3002', 'http://localhost:3003']
    
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
