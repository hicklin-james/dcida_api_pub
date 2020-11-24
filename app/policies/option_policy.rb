class OptionPolicy
  def initialize(user, record)
    raise Exceptions::NotAuthenticatedError, "must be logged in" unless user
    @user = user
    @option = record
    @decision_aid = @option.decision_aid
  end

  class Scope < Struct.new(:user, :scope, :decision_aid)
    def resolve
      decision_aid.options.where(option_id: nil)
    end
  end

  def show?
    @user.is_superadmin || @option.created_by_user_id == @user.id
  end

  def create?
    true
  end

  def clone?
    @user.is_superadmin || @option.created_by_user_id == @user.id
  end

  def update_order?
    @user.is_superadmin || @option.created_by_user_id == @user.id
  end

  def update?
    @user.is_superadmin || @option.created_by_user_id == @user.id
  end

  def destroy?
    @user.is_superadmin || @option.created_by_user_id == @user.id
  end

end
