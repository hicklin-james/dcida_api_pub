class DceQuestionSetResponsePolicy
  def initialize(user, record)
    raise Exceptions::NotAuthenticatedError, "must be logged in" unless user
    @user = user
    @dce_question_set_response = record
    @decision_aid = @dce_question_set_response.decision_aid
  end

  class Scope < Struct.new(:user, :scope, :decision_aid)
    def resolve
      decision_aid.dce_question_set_responses.order(:question_set, :response_value)
    end
  end

end
