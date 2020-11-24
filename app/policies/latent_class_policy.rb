class LatentClassPolicy
  def initialize(user, record)
    raise Exceptions::NotAuthenticatedError, "must be logged in" unless user
    @user = user
    @latent_class = record
    @decision_aid = @latent_class.decision_aid
  end

  class Scope < Struct.new(:user, :scope, :decision_aid)
    def resolve
      decision_aid.latent_classes
    end
  end

  def show?
    @user.is_superadmin || @latent_class.created_by_user_id == @user.id
  end

  def create?
    true
  end

  def clone?
    @user.is_superadmin || @latent_class.created_by_user_id == @user.id
  end

  def update_order?
    @user.is_superadmin || @latent_class.created_by_user_id == @user.id
  end

  def update?
    @user.is_superadmin || @latent_class.created_by_user_id == @user.id
  end

  def destroy?
    @user.is_superadmin || @latent_class.created_by_user_id == @user.id
  end

end
