class DecisionAidUserPolicy
  def initialize(current_da_user, record)
    @decision_aid_user = record
    @current_da_user = current_da_user
  end

  def update?
    @decision_aid_user.id == @current_da_user.id
  end

  def update_from_properties?
    @decision_aid_user.id == @current_da_user.id
  end
end
