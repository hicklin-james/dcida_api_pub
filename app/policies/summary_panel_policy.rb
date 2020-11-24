class SummaryPanelPolicy
  def initialize(user, record)
    raise Exceptions::NotAuthenticatedError, "must be logged in" unless user
    @user = user
    @summary_panel = record
    @decision_aid = @summary_panel.decision_aid
  end

  class Scope < Struct.new(:user, :scope, :decision_aid)
    def resolve
      decision_aid.summary_panels.ordered
    end
  end

  def show?
    @user.is_superadmin || @summary_panel.created_by_user_id == @user.id
  end

  def create?
    true
  end

  def clone?
    @user.is_superadmin || @summary_panel.created_by_user_id == @user.id
  end

  def update_order?
    @user.is_superadmin || @summary_panel.created_by_user_id == @user.id
  end

  def update?
    @user.is_superadmin || @summary_panel.created_by_user_id == @user.id
  end

  def destroy?
    @user.is_superadmin || @summary_panel.created_by_user_id == @user.id
  end

end
