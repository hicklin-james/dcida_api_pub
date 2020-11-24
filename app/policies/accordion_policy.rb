class AccordionPolicy
  def initialize(user, record)
    raise Exceptions::NotAuthenticatedError, "must be logged in" unless user
    @user = user
    @accordion = record
    @decision_aid = @accordion.decision_aid
  end

  class Scope < Struct.new(:user, :scope, :decision_aid)
    def resolve
      decision_aid.accordions
    end
  end

  def show?
    @user.is_superadmin || @accordion.user_id == @user.id
  end

  def create?
    true
  end

  def update?
    @user.is_superadmin || @accordion.user_id == @user.id
  end

  def destroy?
    @user.is_superadmin || @accordion.user_id == @user.id
  end

end
