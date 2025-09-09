class TokenError < BaseError
  HTTP_STATUS = 401
  MESSAGE = 'Invalid or expired token'.freeze
end