class ApplicationOperation
  attr_reader :params

  def self.call(params = {})
    new(params).call
  end

  def initialize(params = {})
    @params = params.with_indifferent_access
  end

  def call
    raise NotImplementedError, "#{self.class} must implement #call"
  end

  private

  def success_response(data = nil, meta = {})
    {
      data: data,
      meta: meta.merge(success: true)
    }
  end

  def error_response(message, error_type = nil, meta = {})
    {
      data: nil,
      meta: meta.merge(
        success: false,
        error: true,
        message: message,
        error_type: error_type
      )
    }
  end
end
