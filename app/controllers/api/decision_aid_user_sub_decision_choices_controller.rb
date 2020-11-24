module Api
  class DecisionAidUserSubDecisionChoicesController < ApplicationController
    before_action :find_decision_aid_user
    before_action :check_user_session

    def index
      choices = DecisionAidUserSubDecisionChoice.where(decision_aid_user_id: @decision_aid_user.id)
      render json: choices
    end

    def find_by_sub_decision_id
      sdc = DecisionAidUserSubDecisionChoice.find_by(decision_aid_user_id: @decision_aid_user.id, sub_decision_id: params[:sub_decision_id])
      if sdc
        render json: sdc
      else
        render json: nil, status: :ok
      end
    end

    def create
      sdc = DecisionAidUserSubDecisionChoice.new(choices_params)
      sdc.decision_aid_user_id = @decision_aid_user.id

      if sdc.save
        sub_decision = sdc.sub_decision
        next_decision = SubDecision.find_by(decision_aid_id: @decision_aid.id, sub_decision_order: sub_decision.sub_decision_order + 1)
        if next_decision and !next_decision.required_option_ids.include?(sdc.option_id)
          next_decision = nil
        end

        render json: sdc,
          meta: {
            next_decision: next_decision
          }
      else
        render json: { errors: sdc.errors.full_messages }, status: 422
      end
    end

    def update
      sdc = DecisionAidUserSubDecisionChoice.find params[:id]

      if sdc.update(choices_params)
        sub_decision = sdc.sub_decision
        next_decision = SubDecision.find_by(decision_aid_id: @decision_aid.id, sub_decision_order: sub_decision.sub_decision_order + 1)
        if next_decision and !next_decision.required_option_ids.include?(sdc.option_id)
          next_decision = nil
        end
        render json: sdc,
          serializer: DecisionAidUserSubDecisionChoiceSerializer,
          meta: {
            next_decision: next_decision
          }
      else
        render json: { errors: sdc.errors.full_messages }, status: 422
      end
    end

    private

    def choices_params
      params.require(:decision_aid_user_sub_decision_choice).permit(:sub_decision_id, :option_id)
    end

    def find_decision_aid_user
      @decision_aid_user = DecisionAidUser.find(params[:decision_aid_user_id])
      @decision_aid = @decision_aid_user.decision_aid
    end

    def pundit_user
      current_decision_aid_user
    end
  end
end