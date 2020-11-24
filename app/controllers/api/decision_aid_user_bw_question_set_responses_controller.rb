module Api
  class DecisionAidUserBwQuestionSetResponsesController < ApplicationController
    before_action :find_decision_aid_user
    before_action :check_user_session

    def create
      daubwqsr = DecisionAidUserBwQuestionSetResponse.new(response_params)
      daubwqsr.decision_aid_user_id = params[:decision_aid_user_id]

      if daubwqsr.save
        render json: daubwqsr
      else
        render json: { errors: daubwqsr.errors.full_messages }, status: 422
      end
    end

    def update
      daubwqsr = DecisionAidUserBwQuestionSetResponse.find(params[:id])

      if daubwqsr.update(response_params)
        render json: daubwqsr
      else
        render json: { errors: daubwqsr.errors.full_messages }, status: 422
      end
    end

    def find_by_question_set
      daubwqsrs = DecisionAidUserBwQuestionSetResponse.where(
        decision_aid_user_id: @decision_aid_user.id,
        question_set: params[:question_set]
      )
      if daubwqsrs.length > 0
        render json: daubwqsrs.first, serializer: DecisionAidUserBwQuestionSetResponseSerializer
      else
        render json: nil
      end
    end

    private

    def response_params
      params.require(:decision_aid_user_bw_question_set_response).permit(:question_set, :best_property_level_id, :worst_property_level_id, :bw_question_set_response_id)
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