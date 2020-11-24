module Api
  class DecisionAidUsersController < ApplicationController
    before_action :get_decision_aid
    before_action :check_user_session

    def update
      authorize @decision_aid_user
      if @decision_aid_user.update(decision_aid_user_params)
        render json: @decision_aid_user
      else
        render json: { errors: @decision_aid_user.errors.full_messages }, status: 422
      end
    end

    def update_from_properties
      authorize @decision_aid_user
      if @decision_aid_user.update(decision_aid_user_params)

        rdts = @decision_aid_user.get_remote_data_targets().pluck(:id)
        if rdts.length > 0
          DataTargetExportWorker.perform_async(rdts, @decision_aid_user.id)
        end

        render json: @decision_aid_user
      else
        render json: { errors: @decision_aid_user.errors.full_messages }, status: 422
      end
    end

    private

    def get_decision_aid
      @decision_aid_user = DecisionAidUser.find(params[:id])
      @decision_aid = @decision_aid_user.decision_aid
    end

    def decision_aid_user_params
      params.require(:decision_aid_user).permit(:selected_option_id, :other_properties)
    end

    def pundit_user
      current_decision_aid_user
    end
  end
end