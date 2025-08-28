class ServiceResponse
  attr_reader :data, :message, :error

  def initialize(success:, data: nil, message: nil, error: nil)
    @success = success
    @data = data
    @message = message
    @error = error
  end

  def success?
    @success
  end

  def error?
    !@success
  end

  def to_h
    {
      success: success?,
      data: data,
      message: message,
      error: error
    }
  end
end