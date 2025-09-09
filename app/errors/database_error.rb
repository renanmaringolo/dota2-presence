class DatabaseError < BaseError
  HTTP_STATUS = 503
  MESSAGE = 'Database service temporarily unavailable'.freeze
end