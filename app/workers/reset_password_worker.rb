class ResetPasswordWorker
  include Sidekiq::Worker

  def perform(user_auth_id, request_origin)
    user_authentication = UserAuthentication.find(user_auth_id)
    if user_authentication
      InviteMailer.reset_password(user_authentication, request_origin).deliver_now
    end
  end
end