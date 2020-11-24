class BwQuestionSetResponsePolicy
  def initialize(user, record)
    raise Exceptions::NotAuthenticatedError, "must be logged in" unless user
    @user = user
    @bw_question_set_response = record
    @decision_aid = @bw_question_set_response.decision_aid
  end

  class Scope < Struct.new(:user, :scope, :decision_aid)
    def resolve
      decision_aid.bw_question_set_responses.order(:question_set)
    end
  end

end
