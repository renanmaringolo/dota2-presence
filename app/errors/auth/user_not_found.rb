class Auth::UserNotFound < BaseError
  HTTP_STATUS = 404
  MESSAGE = 'User not found'.freeze
end