class InviteMailerWorker
  include Sidekiq::Worker

  def perform(user_auth_id, request_origin)
    user_authentication = UserAuthentication.find(user_auth_id)
    if UserAuthentication
      InviteMailer.invite_mail(user_authentication, request_origin).deliver_now
    end
  end
end