class Auth::InvalidCredentials < BaseError
  HTTP_STATUS = 401
  MESSAGE = 'Invalid email or password'.freeze
end
