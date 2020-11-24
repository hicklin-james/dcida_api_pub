module Api
  class SubDecisionsController < ApplicationController
    before_action :doorkeeper_authorize!
    before_action :authenticate!
    before_action :find_decision_aid

    def index
      sub_decisions = SubDecisionPolicy::Scope.new(current_user, SubDecision, @decision_aid).resolve
      render json: sub_decisions
    end

    def create
      sub_decision = SubDecision.new(sub_decision_params)
      sub_decision.decision_aid_id = @decision_aid.id

      if sub_decision.save
        render json: sub_decision
      else
        render json: { errors: sub_decision.errors.full_messages }, status: 422
      end
    end

    def update
      sub_decision = SubDecision.find(params[:id])
      authorize sub_decision

      if sub_decision.update(sub_decision_params)
        render json: sub_decision
      else
        render json: { errors: sub_decision.errors.full_messages }, status: 422
      end
    end

    def show
      sub_decision = SubDecision.find(params[:id])
      authorize sub_decision
      render json: sub_decision, serializer: SubDecisionSerializer
    end

    private

    def find_decision_aid
      @decision_aid = DecisionAid.find params[:decision_aid_id]
    end

    def sub_decision_params
      params[:required_option_ids] ||= [] if params.has_key?(:required_option_ids)
      params.require(:sub_decision).permit(:options_information, :option_question_text, :other_options_information,  :my_choice_information, :required_option_ids => [])
    end
  end
end