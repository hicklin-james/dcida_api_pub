module Api
  class BasicPageSubmissionsController < ApplicationController
    before_action :find_decision_aid_user
    before_action :check_user_session

    def index
      submissions = BasicPageSubmissionPolicy::Scope.new(BasicPageSubmission, @decision_aid_user).resolve
      if params.has_key?(:only_intro_pages)
        submissions = submissions.where.not(intro_page_id: nil)
      end
      if params.has_key?(:intro_page_id)
        submissions = submissions.where(intro_page_id: params[:intro_page_id])
      end
      render json: submissions
    end

    def create
      ### ###
      bps = BasicPageSubmission.new(page_submission_params)
      authorize bps
      bps.decision_aid_user_id = @decision_aid_user.id
      if bps.save
        render json: bps
      else
        render json: { errors: bps.errors.full_messages }, status: 422
      end
    end

    private

    def page_submission_params
      params.require(:basic_page_submission).permit(:option_id, :intro_page_id, :sub_decision_id)
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