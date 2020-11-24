class QuestionPolicy
  def initialize(user, record)
    raise Exceptions::NotAuthenticatedError, "must be logged in" unless user
    @user = user
    @question = record
    @decision_aid = @question.decision_aid
  end

  class Scope < Struct.new(:user, :scope, :decision_aid)
    def resolve
      decision_aid.questions.where(question_id: nil)
    end
  end

  def show?
    @user.is_superadmin || @question.created_by_user_id == @user.id
  end

  def create?
    true
  end

  def clone?
    @user.is_superadmin || @question.created_by_user_id == @user.id
  end

  def update_order?
    @user.is_superadmin || @question.created_by_user_id == @user.id
  end

  def move_question_to_page?
    @user.is_superadmin || @question.created_by_user_id == @user.id
  end

  def update?
    @user.is_superadmin || @question.created_by_user_id == @user.id
  end

  def destroy?
    @user.is_superadmin || @question.created_by_user_id == @user.id
  end

  def test_redcap_question?
    @user.is_superadmin || @question.created_by_user_id == @user.id
  end

end
