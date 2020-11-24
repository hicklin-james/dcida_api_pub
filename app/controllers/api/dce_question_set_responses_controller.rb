module Api
  class DceQuestionSetResponsesController < ApplicationController
    before_action :doorkeeper_authorize!
    before_action :authenticate!
    before_action :find_decision_aid

    def index  
      dceQuestionSetResponses = DceQuestionSetResponsePolicy::Scope.new(current_user, Question, @decision_aid).resolve
      if params.has_key?(:question_set)
        dceQuestionSetResponses = dceQuestionSetResponses.where(question_set: params[:question_set])
      end
      if params.has_key?(:block)
        dceQuestionSetResponses = dceQuestionSetResponses.where(block_number: params[:block])
      end
      render json: dceQuestionSetResponses
    end

    def preview
      dce_question_set_responses = DceQuestionSetResponsePolicy::Scope.new(current_user, DceQuestionSetResponse, @decision_aid).resolve
      render json: dce_question_set_responses, each_serializer: DceQuestionSetResponsePreviewSerializer
    end

    private

    def find_decision_aid
      @decision_aid = DecisionAid.find params[:decision_aid_id]
    end
  end
end