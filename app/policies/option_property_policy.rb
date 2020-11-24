class OptionPropertyPolicy
  def initialize(user, record)
    raise Exceptions::NotAuthenticatedError, "must be logged in" unless user
    @user = user
    @option_property = record
    @decision_aid = @option_property.decision_aid
  end

  class Scope < Struct.new(:user, :scope, :decision_aid)
    def resolve
      decision_aid.option_properties
    end
  end

  def show?
    @user.is_superadmin || @option_property.created_by_user_id == @user.id
  end

  def create?
    true
  end

  def update?
    @user.is_superadmin || @option_property.created_by_user_id == @user.id
  end

  def destroy?
    @user.is_superadmin || @option_property.created_by_user_id == @user.id
  end

  def update_bulk?
    @user.is_superadmin || @option_property.created_by_user_id == @user.id
  end

end
