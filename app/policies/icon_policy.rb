class IconPolicy
  def initialize(user, record)
    raise Exceptions::NotAuthenticatedError, "must be logged in" unless user
    @user = user
    @icon = record
    @decision_aid = @icon.decision_aid
  end

  class Scope < Struct.new(:user, :scope, :decision_aid)
    def resolve
      decision_aid.icons
    end
  end

  def create?
    true
  end

  def update?
    @user.is_superadmin || @icon.created_by_user_id == @user.id
  end

  def destroy?
    @user.is_superadmin || @icon.created_by_user_id == @user.id
  end

end
