class Auth::InvalidCredentials < StandardError
  def initialize(msg = 'Invalid email or password')
    super(msg)
  end
end