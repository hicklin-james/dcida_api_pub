module Api
  class DecisionAidUserPropertiesController < ApplicationController
    before_action :find_decision_aid_user
    before_action :check_user_session

    def index
      decision_aid_user_properties = DecisionAidUserPropertyPolicy::Scope.new(DecisionAidUserProperty, @decision_aid_user).resolve
      
      if params.has_key?(:property_ids)
        decision_aid_user_properties = decision_aid_user_properties.where(property_id: params[:property_ids])
      end

      render json: decision_aid_user_properties
    end

    def update_selections
      if !params.has_key?(:decision_aid_user_properties)
        render json: { errors: {decision_aid_user_properties: [{"Exceptions::MissingParams" => 'ParamMissing'}]}}, status: 400
      else
        begin
          updated_properties = update_params[:properties].select{ |daup| !daup["id"].nil? }
          created_properties = update_params[:properties].select{ |daup| daup["id"].nil? }
          items = DecisionAidUserPropertyService.add_or_remove_user_properties(@decision_aid_user, updated_properties, created_properties)

          rdts = Property.get_remote_data_targets(items.map(&:property_id)).pluck(:id)
          if rdts.length > 0
            DataTargetExportWorker.perform_async(rdts, @decision_aid_user.id)
          end

          render json: {decision_aid_user_properties: items}
        rescue => error
          render json: { errors: {decision_aid_user_properties: [{"#{error.class}" => error.message}]}}, status: 400
        end
      end
    end

    private

    def update_params
      params[:decision_aid_user_properties][:properties] ||= [] if params.has_key?(:decision_aid_user_properties) and params[:decision_aid_user_properties].has_key?(:properties)
      params.require(:decision_aid_user_properties).permit(:properties => [:id, :property_id, :decision_aid_user_id, :weight, :order, :color, :traditional_value, :traditional_option_id])
    end

    def find_decision_aid_user
      @decision_aid_user = DecisionAidUser.includes(:decision_aid_user_properties => [:property]).find(params[:decision_aid_user_id])
      @decision_aid = @decision_aid_user.decision_aid
    end

    def pundit_user
      current_decision_aid_user
    end
  end
end