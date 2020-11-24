module Api
  class DecisionAidUserDceQuestionSetResponsesController < ApplicationController
    before_action :find_decision_aid_user
    before_action :check_user_session

    def create
      daudqsr = DecisionAidUserDceQuestionSetResponse.new(response_params)
      daudqsr.decision_aid_user_id = params[:decision_aid_user_id]

      if daudqsr.save
        render json: daudqsr
      else
        render json: { errors: daudqsr.errors.full_messages }, status: 422
      end
    end

    def update
      daudqsr = DecisionAidUserDceQuestionSetResponse.find(params[:id])
      authorize daudqsr

      if daudqsr.update(response_params)
        render json: daudqsr
      else
        render json: { errors: daudqsr.errors.full_messages }, status: 422
      end
    end

    def find_by_question_set
      daudqsr = DecisionAidUserDceQuestionSetResponse.find_by(
        decision_aid_user_id: @decision_aid_user.id,
        question_set: params[:question_set]
      )
      if daudqsr
        render json: daudqsr, serializer: DecisionAidUserDceQuestionSetResponseSerializer
      else
        render json: {}
      end
    end

    private

    def response_params
      params.require(:decision_aid_user_dce_question_set_response).permit(:dce_question_set_response_id, :question_set, :fallback_question_set_id, :option_confirmed)
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