module Api
  class DecisionAidUserOptionPropertiesController < ApplicationController
    before_action :find_decision_aid_user
    before_action :check_user_session

    def index
      decision_aid_user_option_properties = DecisionAidUserOptionPropertyPolicy::Scope.new(DecisionAidUserOptionProperty, @decision_aid_user).resolve
      if params.has_key?(:option_ids)
        decision_aid_user_option_properties = decision_aid_user_option_properties.where(option_id: params[:option_ids])
      end 
      render json: decision_aid_user_option_properties
    end

    def update_user_option_properties
      if !params.has_key?(:decision_aid_user_option_properties)
        render json: { errors: {decision_aid_user_option_properties: [{"Exceptions::MissingParams" => 'ParamMissing'}]}}, status: 400
      else
        updated_option_properties = update_params[:option_properties].select{ |dauop| !dauop["id"].nil? }.map {|op| [op[:id], op]}.to_h
        created_option_properties = update_params[:option_properties].select{ |dauop| dauop["id"].nil? }

        option_properties = []
        #ids = updated_option_properties.map {|k,v| k}
        begin
          DecisionAidUserOptionProperty.update_values(updated_option_properties, option_properties, @decision_aid_user.id)
          if created_option_properties.length > 0
            DecisionAidUserOptionProperty.transaction do
              created_option_properties.each do |dauop_params|
                option_properties.push DecisionAidUserOptionProperty.create!(dauop_params)
              end
            end
          end
          render json: option_properties
        rescue => error
          render json: { errors: {decision_aid_user_option_properties: [{"#{error.class}" => error.message}]}}, status: 400
        end
      end
    end

    private

    def update_params
      params[:decision_aid_user_option_properties][:option_properties] ||= [] if params.has_key?(:decision_aid_user_option_properties) and 
                                                                                 params[:decision_aid_user_option_properties].has_key?(:option_properties)
      params.require(:decision_aid_user_option_properties).permit(:option_properties => [:id, :property_id, :option_id, :option_property_id, :decision_aid_user_id, :value])
    end

    def find_decision_aid_user
      @decision_aid_user = DecisionAidUser.includes(:decision_aid_user_option_properties).find(params[:decision_aid_user_id])
      @decision_aid = @decision_aid_user.decision_aid
    end
    
    def pundit_user
      current_decision_aid_user
    end
  end
end