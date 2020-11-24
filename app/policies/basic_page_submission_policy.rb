class BasicPageSubmissionPolicy
  def initialize(user, record)
    raise Exceptions::NotAuthenticatedError, "must be logged in" unless user
    @decision_aid_user = user
    @basic_page_submission = record
  end

  class Scope < Struct.new(:scope, :decision_aid_user)
    def resolve
      scope.where(decision_aid_user_id: decision_aid_user.id)
    end
  end

  def create?
    true
  end

  def show?
    @basic_page_submission.decision_aid_user_id == @decision_aid_user.id
  end

end
