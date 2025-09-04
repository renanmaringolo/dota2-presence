class Auth::UserNotFound < StandardError
  def initialize(msg = 'User not found')
    super(msg)
  end
end
