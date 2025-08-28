module Admin
  class BaseController < ApplicationController
    before_action :authenticate_admin

    private

    def authenticate_admin
      # Simple authentication for now - can be enhanced with proper auth system
      # For MVP, using basic token authentication
      token = request.headers['Authorization']&.gsub('Bearer ', '')
      
      unless valid_admin_token?(token)
        render_error('Unauthorized access', :unauthorized)
      end
    end

    def valid_admin_token?(token)
      return false if token.blank?
      
      # For development, allow any token that starts with 'admin_'
      if Rails.env.development?
        token.start_with?('admin_')
      else
        # In production, this should validate against a secure token
        # stored in environment variables or database
        token == ENV['ADMIN_TOKEN']
      end
    end
  end
end