class UserAuthenticationPolicy
  def initialize(user, record)
    raise Exceptions::NotAuthenticatedError, "must be logged in" unless user
    @current_user = user
    @user_authentication = record
  end

  def create?
    @current_user.is_superadmin
  end

end
