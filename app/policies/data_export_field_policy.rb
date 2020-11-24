class DataExportFieldPolicy
  def initialize(user, record)
    raise Exceptions::NotAuthenticatedError, "must be logged in" unless user
    @user = user
    @data_export_field = record
    @decision_aid = @data_export_field.decision_aid
  end

  class Scope < Struct.new(:user, :scope, :decision_aid)
    def resolve
      decision_aid.data_export_fields
    end
  end

  def show?
    @user.is_superadmin || @data_export_field.created_by_user_id == @user.id
  end

  def create?
    true
  end

  def update_order?
    @user.is_superadmin || @data_export_field.created_by_user_id == @user.id
  end

  def clone?
    @user.is_superadmin || @data_export_field.created_by_user_id == @user.id
  end

  def update?
    @user.is_superadmin || @data_export_field.created_by_user_id == @user.id
  end

  def destroy?
    @user.is_superadmin || @data_export_field.created_by_user_id == @user.id
  end

end
