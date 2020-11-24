class NavLinkPolicy
  def initialize(user, record)
    raise Exceptions::NotAuthenticatedError, "must be logged in" unless user
    @user = user
    @nav_link = record
    @decision_aid = @nav_link.decision_aid
  end

  class Scope < Struct.new(:user, :scope, :decision_aid)
    def resolve
      decision_aid.nav_links.ordered
    end
  end

  def show?
    @user.is_superadmin || @nav_link.created_by_user_id == @user.id
  end

  def create?
    true
  end

  def clone?
    @user.is_superadmin || @nav_link.created_by_user_id == @user.id
  end

  def update_order?
    @user.is_superadmin || @nav_link.created_by_user_id == @user.id
  end

  def update?
    @user.is_superadmin || @nav_link.created_by_user_id == @user.id
  end

  def destroy?
    @user.is_superadmin || @nav_link.created_by_user_id == @user.id
  end

end
