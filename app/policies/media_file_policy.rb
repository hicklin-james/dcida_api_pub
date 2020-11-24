class MediaFilePolicy
  def initialize(user, record)
    raise Exceptions::NotAuthenticatedError, "must be logged in" unless user
    @user = user
    @option = record
  end

  class Scope < Struct.new(:user, :scope)
    def resolve
      user.media_files.ordered
    end
  end

  def create?
    true
  end
end
