class DecisionAidUserResponsePolicy
  def initialize(user, record)
    @decision_aid_user_response = record
    @user = user
  end

  class Scope < Struct.new(:scope, :decision_aid_user)
    def resolve
      decision_aid_user.decision_aid_user_responses
    end
  end

  def show?
    @decision_aid_user_response.decision_aid_user_id == @user.id
  end

  def create_or_update_radio_from_chatbot?
    true
  end

  def create?
    true
  end

  def update?
    true
  end
end
