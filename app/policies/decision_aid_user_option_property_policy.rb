class DecisionAidUserOptionPropertyPolicy
  def initialize(user, record)
    @decision_aid_user_option_property = record
  end

  class Scope < Struct.new(:scope, :decision_aid_user)
    def resolve
      decision_aid_user.decision_aid_user_option_properties
    end
  end

end
