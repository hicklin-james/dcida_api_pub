class DecisionAidUserDceQuestionSetResponsePolicy
  def initialize(user, record)
    @dau = user
    @decision_aid_user_dce_question_set_response = record
  end

  def update?
    @dau.id == @decision_aid_user_dce_question_set_response.decision_aid_user_id
  end

end