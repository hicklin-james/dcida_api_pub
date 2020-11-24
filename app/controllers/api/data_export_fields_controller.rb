module Api
  class DataExportFieldsController < ApplicationController
    before_action :doorkeeper_authorize!
    before_action :authenticate!
    before_action :find_decision_aid

    def show
      data_export_field = DataExportField.find(params[:id])
      authorize data_export_field
      render json: data_export_field
    end

    def index
      data_export_fields = DataExportFieldPolicy::Scope.new(current_user, DataExportField, @decision_aid).resolve.list_scope
      render json: data_export_fields, each_serializer: DataExportFieldListSerializer
    end

    def create
      data_export_field = DataExportField.new(data_export_field_params)
      data_export_field.decision_aid = @decision_aid
      data_export_field.initialize_order(@decision_aid.data_export_fields.count)
      if data_export_field.exporter_type == "Other"
        data_export_field.exporter_id = -1
      end
      authorize data_export_field

      if data_export_field.save
        render json: data_export_field
      else
        render json: { errors: data_export_field.errors.full_messages }, status: 422
      end

    end

    def update
      data_export_field = DataExportField.find(params[:id])
      authorize data_export_field

      if data_export_field.update(data_export_field_params)
        render json: data_export_field
      else
        render json: { errors: data_export_field.errors.full_messages }, status: 422
      end
      
    end
 
    def destroy
      data_export_field = DataExportField.find(params[:id])
      authorize data_export_field

      if data_export_field.destroy
        render json: { message: "removed" }, status: :ok
      else
        render json: { errors: data_export_field.errors.full_messages }, status: 422
      end
    end

    def update_order
      data_export_field = DataExportField.find(params[:id])
      authorize data_export_field

      data_export_field.change_order(data_export_field_params[:data_export_field_order])
      render json: property
    end

    def test_redcap_question
      redcap_service = RedcapService.new(@decision_aid)
      r = redcap_service.test_question(params[:redcap_question_variable])
      if r.has_key?(:body)
        render json: r[:body], serializer: nil
      else
        render json: {errors: [r[:error]]}, status: 400
      end
    end

    private

    def data_export_field_params
      params.require(:data_export_field).permit(:exporter_id, :exporter_type, :data_target_type, :redcap_field_name, 
                     :redcap_response_mapping, :data_export_field_order, :data_accessor).tap do |whitelisted|
        whitelisted[:redcap_response_mapping] = params[:data_export_field][:redcap_response_mapping].permit!
      end
    end

    def find_decision_aid
      @decision_aid = DecisionAid.find params[:decision_aid_id]
    end
  end
end