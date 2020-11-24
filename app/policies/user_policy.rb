class UserPolicy
  def initialize(user, record)
    raise Exceptions::NotAuthenticatedError, "must be logged in" unless user
    @current_user = user
    @user = record
  end

  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.is_superadmin
        scope.all
      else
        scope.where(id: user.id)
      end
    end
  end

  def show?
    @current_user.is_superadmin || @current_user.id == @user.id
  end

  def create_from_admin?
    @current_user.is_superadmin
  end

  def update?
    @current_user.is_superadmin || @current_user.id == @user.id
  end

  def destroy?
    @current_user.is_superadmin
  end

end
