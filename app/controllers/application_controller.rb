class ApplicationController < ActionController::Base
  include Pundit

  rescue_from Exceptions::NotAuthenticatedError, with: :user_not_authenticated
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authenticated

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  before_action :store_request_host

  protected

  def current_user
    User.current_user
  end

  def check_user_session
    @user_session = check_current_session_valid(@decision_aid_user)
  end

  def current_decision_aid_user
    decision_aid_user_id = request.headers["DECISION-AID-USER-ID"]
    if decision_aid_user_id
      dau = DecisionAidUser.find_by(id: decision_aid_user_id)
      session_invalid("no_user") and return if !dau
      @user_session = check_current_session_valid(dau)
      dau
    else
      session_invalid("no_user")
    end
  end

  def authenticated?
    !User.current_user.nil?
  end

  def authenticate!
    user = User.find_by(id: doorkeeper_token.resource_owner_id) if doorkeeper_token
    if user
      User.current_user = user
    else
      request_http_token_authentication
    end
  end

  private

  def session_invalid(reason="session_expired")
    render json: {error: reason}, status: :unauthorized
  end

  def store_request_host
    RequestStore.store[:protocol] = request.protocol
    RequestStore.store[:host_with_port] = request.host_with_port

    if request.headers['origin']
      RequestStore.store[:origin] = request.headers['origin']
    else
      # not CORS, so set origin to host (fixes some IE problems)
      RequestStore.store[:origin] = request.protocol + request.host
    end

    true
  end

  def user_not_authenticated
    render json: { error: 'Unauthorized'}, status: :forbidden
  end

  def check_current_session_valid(dau)
    user_session_query = DecisionAidUserSession.where(decision_aid_user_id: dau.id)
    if user_session_query.length == 1
      user_session = user_session_query.first
      if !user_session.blank? and (user_session.last_access + 1.day) > Time.now
        if dau.decision_aid_id == @decision_aid.id
          user_session.last_access = Time.now
          if user_session.save
            user_session
          else
            session_invalid
          end
        else
          user_session.destroy
          session_invalid
        end
      else
        user_session.destroy
        session_invalid
      end
    else
      session_invalid
    end
  end
end
