class InviteMailer < ApplicationMailer
  def invite_mail(user_authentication, request_origin)
    address = user_authentication.email
    @user_authentication = user_authentication
    @request_origin = request_origin
    mail(to: address, 
         subject: "You have been invited to create a user on DCIDA", 
         from: "noreply@#{ENV['MAILER_BASE']}")
  end

  def reset_password(user_authentication, request_origin)
    address = user_authentication.email
    @user_authentication = user_authentication
    @request_origin = request_origin
    mail(to: address,
         subject: "Password reset request on DCIDA",
         from: "noreply@#{ENV['MAILER_BASE']}"
      )
  end
end
