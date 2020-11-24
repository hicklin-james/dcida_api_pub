class DecisionAidPolicy
  def initialize(user, record)
    raise Exceptions::NotAuthenticatedError, "must be logged in" unless user
    @user = user
    @decision_aid = record
  end

  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.is_superadmin
        scope.all
      else
        scope.where(created_by_user_id: user.id)
      end
    end
  end

  def show?
    @user.is_superadmin || @decision_aid.created_by_user_id == @user.id
  end

  def page_targets?
    @user.is_superadmin || @decision_aid.created_by_user_id == @user.id
  end

  def create?
    @user.is_superadmin
  end

  def clear_user_data?
    @user.is_superadmin || @decision_aid.created_by_user_id == @user.id
  end

  def update?
    @user.is_superadmin || @decision_aid.created_by_user_id == @user.id
  end

  def destroy?
    @user.is_superadmin || @decision_aid.created_by_user_id == @user.id
  end

  def preview?
    @user.is_superadmin || @decision_aid.created_by_user_id == @user.id
  end

  def upload_dce_design?
    @user.is_superadmin || @decision_aid.created_by_user_id == @user.id
  end

  def upload_dce_results?
    @user.is_superadmin || @decision_aid.created_by_user_id == @user.id
  end

  def upload_bw_design?
    @user.is_superadmin || @decision_aid.created_by_user_id == @user.id
  end

  def setup_dce?
    @user.is_superadmin || @decision_aid.created_by_user_id == @user.id
  end

  def setup_bw?
    @user.is_superadmin || @decision_aid.created_by_user_id == @user.id
  end

  def export?
    @user.is_superadmin || @decision_aid.created_by_user_id == @user.id
  end

  def download_user_data?
    @user.is_superadmin || @decision_aid.created_by_user_id == @user.id
  end

  def test_redcap_connection?
    @user.is_superadmin || @decision_aid.created_by_user_id == @user.id
  end
end
