module Api
  class UserAuthenticationsController < ApplicationController
    before_action :doorkeeper_authorize! , except: [:reset_password]
    before_action :authenticate!, except: [:reset_password]

    def create
      token = SecureRandom.urlsafe_base64(nil, false)
      params[:user_authentication][:token] = token if params.has_key?(:user_authentication)
      params[:user_authentication][:is_superuser] = false if params.has_key?(:user_authentication) and !params[:user_authentication].has_key?(:is_superuser)
      user_auth = UserAuthentication.new(user_authentication_params)
      authorize user_auth

      if user_auth.save
        # send email to confirm account
        InviteMailerWorker.perform_async(user_auth.id, RequestStore.store[:origin])
        render json: user_auth, serializer: UserAuthenticationSerializer
      else
        render json: { errors: user_auth.errors.full_messages }, status: 422
      end
    end

    def reset_password
      token = SecureRandom.urlsafe_base64(nil, false)
      params[:user_authentication][:token] = token if params.has_key?(:user_authentication)
      target_email = params[:user_authentication][:email] if params.has_key?(:user_authentication)

      if u = User.find_by_email(target_email)
        user_auth = UserAuthentication.new(user_authentication_params)
        if user_auth.save
          ResetPasswordWorker.perform_async(user_auth.id, RequestStore.store[:origin])
          render json: user_auth, serializer: UserAuthenticationSerializer
        else
          render json: { errors: user_auth.errors.full_messages }, status: 422
          user_auth.destroy
        end
      else
        render json: {errors: ["No user with found matching email."]}, status: 422
      end
    end

    private

    def user_authentication_params
      params.require(:user_authentication).permit(:is_superuser, :token, :email)
    end
  end
end