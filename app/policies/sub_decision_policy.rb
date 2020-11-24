class SubDecisionPolicy
  def initialize(user, record)
    raise Exceptions::NotAuthenticatedError, "must be logged in" unless user
    @user = user
    @sub_decision = record
    @decision_aid = @sub_decision.decision_aid
  end

  class Scope < Struct.new(:user, :scope, :decision_aid)
    def resolve
      decision_aid.sub_decisions
    end
  end

  def show?
    @user.is_superadmin || @sub_decision.created_by_user_id == @user.id
  end

  def create?
    true
  end

  def update?
    @user.is_superadmin || @sub_decision.created_by_user_id == @user.id
  end
end
