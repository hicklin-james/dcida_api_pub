class PropertyPolicy
  def initialize(user, record)
    raise Exceptions::NotAuthenticatedError, "must be logged in" unless user
    @user = user
    @property = record
    @decision_aid = @property.decision_aid
  end

  class Scope < Struct.new(:user, :scope, :decision_aid)
    def resolve
      decision_aid.properties
    end
  end

  def show?
    @user.is_superadmin || @property.created_by_user_id == @user.id
  end

  def create?
    true
  end

  def update_order?
    @user.is_superadmin || @property.created_by_user_id == @user.id
  end

  def clone?
    @user.is_superadmin || @property.created_by_user_id == @user.id
  end

  def update?
    @user.is_superadmin || @property.created_by_user_id == @user.id
  end

  def destroy?
    @user.is_superadmin || @property.created_by_user_id == @user.id
  end

end
