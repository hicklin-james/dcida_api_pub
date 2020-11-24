module Api
  class UsersController < ApplicationController
    before_action :doorkeeper_authorize!, except: [:create, :reset_password]
    before_action :authenticate!, except: [:create, :reset_password]

    def show
      user = User.find params[:id]
      authorize user

      render json: user
    end

    def index
      decision_aids = policy_scope(User)
      render json: decision_aids
    end

    def create_from_admin
      user = User.new(user_new_params)
      authorize user

      if user.save
        render json: user
      else
        render json: {errors: user.errors.full_messages}, status: 422
      end
    end

    def create
      if user_new_params.has_key?(:is_superadmin)
        user_new_params.delete(:is_superadmin)
      end

      user = User.new(user_new_params)

      ua = UserAuthentication.find_by(token: params[:creation_token])
      if !ua
        render json: {errors: ["No user authentication token found. Ensure you use the link provided in the invitation email."]}, status: 422
      elsif ua.validate_user_auth(user) and user.save
        ua.destroy!
        render json: user
      else
        render json: {errors: user.errors.full_messages}, status: 422
      end
    end

    def reset_password
      user = User.find_by_email(user_password_params[:email])
      if user
        ua = UserAuthentication.find_by(token: params[:token])
        if !ua
          render json: {errors: ["No user authentication token found. Ensure you use the link provided in the reset email."]}, status: 422
        elsif ua.validate_user_auth(user) and user.update(user_password_params)
          ua.destroy!
          render json: user
        else
          render json: {errors: user.errors.full_messages}, status: 422
        end
      else
        render json: {errors: ["No user found with requested email"]}
      end
    end

    def update
      user = User.find params[:id]
      authorize user

      if user_update_params.has_key?(:is_superadmin) and !current_user.is_superadmin
        user_update_params.delete(:is_superadmin)
      end

      if user.update(user_update_params)
        render json: user
      else
        render json: {errors: user.errors.full_messages}, status: 422
      end
    end

    def destroy
      user = User.find params[:id]
      authorize user

      if user.destroy
        render json: { message: "removed" }, status: :ok
      else
        render json: { errors: user.errors.full_messages }, status: 422
      end
    end

    def current
      render json: current_user
    end

    private

    def user_new_params
      params.require(:user).permit(:first_name, :last_name, :is_superadmin, :password, :password_confirmation, :email, :terms_accepted)
    end

    def user_update_params
      params.require(:user).permit(:first_name, :last_name, :is_superadmin)
    end

    def user_password_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
  end
end