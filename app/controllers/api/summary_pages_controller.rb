module Api
  class SummaryPagesController < ApplicationController
    before_action :doorkeeper_authorize!
    before_action :authenticate!
    before_action :find_decision_aid

    def show
      summary_page = SummaryPage.find(params[:id])
      authorize summary_page
      render json: summary_page
    end

    def index
      summary_pages = SummaryPagePolicy::Scope.new(current_user, SummaryPage, @decision_aid).resolve
      render json: summary_pages, each_serializer: SummaryPageSerializer
    end

    def create
      summary_page = SummaryPage.new(summary_page_params)
      summary_page.decision_aid = @decision_aid
      authorize summary_page

      if summary_page.save
        render json: summary_page, serializer: SummaryPageSerializer
      else
        render json: { errors: summary_page.errors.full_messages }, status: 422
      end
    end

    def update
      summary_page = SummaryPage.find(params[:id])
      authorize summary_page

      if summary_page.update(summary_page_params)
        render json: summary_page, serializer: SummaryPageSerializer
      else
        render json: { errors: summary_page.errors.full_messages }, status: 422
      end 
    end

    def destroy
      summary_page = SummaryPage.find(params[:id])
      authorize summary_page

      if summary_page.destroy
        render json: { message: "removed" }, status: :ok
      else
        render json: { errors: summary_page.errors.full_messages }, status: 422
      end
    end

    private

    def summary_page_params
      params[:summary_page][:summary_email_addresses] ||= [] if params.has_key?(:summary_page) and params[:summary_page].has_key?(:summary_email_addresses)

      params.require(:summary_page).permit(:include_admin_summary_email, :is_primary, :backend_identifier, :summary_email_addresses => [])
    end

    def find_decision_aid
      @decision_aid = DecisionAid.find params[:decision_aid_id]
    end
  end
end