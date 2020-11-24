class DceQuestionSetPolicy
  def initialize(user, record)
    raise Exceptions::NotAuthenticatedError, "must be logged in" unless user
    @user = user
    @dce_question_set = record
    @decision_aid = @dce_question_set.decision_aid
  end

  class Scope < Struct.new(:user, :scope, :decision_aid)
    def resolve
      decision_aid.dce_question_sets.ordered
    end
  end

  def update_bulk?
    @user.is_superadmin || @decision_aid.created_by_user_id == @user.id
  end

end
