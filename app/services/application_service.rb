class ApplicationService
  def self.call(*args)
    new(*args).call
  end

  def call
    raise NotImplementedError, "Subclasses must implement #call method"
  end

  private

  def success(data: nil, message: nil)
    ServiceResponse.new(success: true, data: data, message: message)
  end

  def error(message, data: nil)
    ServiceResponse.new(success: false, error: message, data: data)
  end

  def log_info(message, data = {})
    Rails.logger.info("#{self.class.name}: #{message} #{data}")
  end

  def log_error(message, exception = nil, data = {})
    Rails.logger.error("#{self.class.name}: #{message} #{data}")
    Rails.logger.error("Exception: #{exception}") if exception
  end
end