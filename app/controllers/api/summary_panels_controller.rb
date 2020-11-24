module Api
  class SummaryPanelsController < ApplicationController
    before_action :doorkeeper_authorize!
    before_action :authenticate!
    before_action :find_decision_aid

    def show
      summary_panel = SummaryPanel.includes(:decision_aid).find(params[:id])
      authorize summary_panel
      render json: summary_panel
    end

    def index
      summary_panels = SummaryPanelPolicy::Scope.new(current_user, SummaryPanel, @decision_aid).resolve
      render json: summary_panels, each_serializer: SummaryPanelSerializer
    end

    def create
      summary_panel = SummaryPanel.new(summary_panel_params)
      summary_panel.decision_aid = @decision_aid
      summary_panel.initialize_order(SummaryPanel.where(decision_aid_id: @decision_aid.id, summary_page_id: summary_panel.summary_page_id).count)
      authorize summary_panel

      if summary_panel.save!
        render json: summary_panel, serializer: SummaryPanelSerializer
      else
        render json: { errors: summary_panel.errors.full_messages }, status: 422
      end
    end

    def update
      summary_panel = SummaryPanel.find(params[:id])
      authorize summary_panel

      if summary_panel.update(summary_panel_params)
        render json: summary_panel, serializer: SummaryPanelSerializer
      else
        render json: { errors: summary_panel.errors.full_messages }, status: 422
      end
      
    end

    def destroy
      summary_panel = SummaryPanel.find(params[:id])
      authorize summary_panel

      if summary_panel.destroy
        render json: { message: "removed" }, status: :ok
      else
        render json: { errors: summary_panel.errors.full_messages }, status: 422
      end
    end

    def update_order
      summary_panel = SummaryPanel.find(params[:id])
      authorize summary_panel

      summary_panel.change_order(summary_panel_params[:summary_panel_order])
      render json: summary_panel, serializer: SummaryPanelSerializer
    end

    private

    def summary_panel_params
      params[:question_ids] ||= [] if params.has_key?(:question_ids) and params[:question_ids].nil?
      params.require(:summary_panel).permit(:panel_type, :panel_information, :summary_panel_order,
        :summary_page_id,
        :injectable_decision_summary_string, :question_ids => []).tap do |whitelisted|
        if params[:summary_panel][:option_lookup_json]
          whitelisted[:option_lookup_json] = params[:summary_panel][:option_lookup_json].permit!
        end
        if params[:summary_panel][:lookup_headers_json]
          whitelisted[:lookup_headers_json] = params[:summary_panel][:lookup_headers_json].permit!
        end
        if params[:summary_panel][:summary_table_header_json]
          whitelisted[:summary_table_header_json] = params[:summary_panel][:summary_table_header_json].permit!
        end
      end
    end

    def find_decision_aid
      @decision_aid = DecisionAid.find params[:decision_aid_id]
    end
  end
end