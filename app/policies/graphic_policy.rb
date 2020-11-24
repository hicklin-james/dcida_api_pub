class GraphicPolicy
  def initialize(user, record)
    raise Exceptions::NotAuthenticatedError, "must be logged in" unless user
    @user = user
    @graphic = record
    @decision_aid = @graphic.decision_aid
  end

  class Scope < Struct.new(:user, :scope, :decision_aid)
    def resolve
      decision_aid.graphics
    end
  end

  def create?
    true
  end

  def update?
    @user.is_superadmin || @graphic.created_by_user_id == @user.id
  end

  def destroy?
    @user.is_superadmin || @graphic.created_by_user_id == @user.id
  end
end