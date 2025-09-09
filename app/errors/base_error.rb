class BaseError < StandardError
  HTTP_STATUS = 500
  MESSAGE = 'Internal Server Error'.freeze

  def self.http_status
    self::HTTP_STATUS
  end

  def self.default_message
    self::MESSAGE
  end

  def http_status
    self.class.http_status
  end

  def default_message
    self.class.default_message
  end

  def initialize(msg = nil)
    super(msg || default_message)
  end
end