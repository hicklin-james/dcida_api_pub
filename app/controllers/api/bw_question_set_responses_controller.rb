module Api
  class BwQuestionSetResponsesController < ApplicationController
    before_action :doorkeeper_authorize!
    before_action :authenticate!
    before_action :find_decision_aid

    def preview
      bw_question_set_responses = BwQuestionSetResponsePolicy::Scope.new(current_user, BwQuestionSetResponse, @decision_aid).resolve
      # bw_question_set_responses = bw_question_set_responses.includes(:property_levels)
      render json: bw_question_set_responses, each_serializer: BwQuestionSetResponsePreviewSerializer
    end

    private

    def find_decision_aid
      @decision_aid = DecisionAid.find params[:decision_aid_id]
    end
  end
end