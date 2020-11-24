module Api
  class OptionPropertiesController < ApplicationController
    before_action :doorkeeper_authorize!
    before_action :authenticate!
    before_action :find_decision_aid

    def show
      option_property = OptionProperty.includes(:decision_aid).find(params[:id])
      authorize option_property
      render json: option_property
    end

    def index
      option_properties = OptionPropertyPolicy::Scope.new(current_user, OptionProperty, @decision_aid).resolve.includes(:property)
      if params.has_key?(:option_id)
        option_properties = option_properties.where(option_id: params[:option_id])
      end
      if params.has_key?(:super_option_id)
        option_properties = option_properties.includes(:option).where("options.option_id = ?", params[:super_option_id]).references(:option)
      end
      if params.has_key?(:property_id)
        option_properties = option_properties.where(property_id: params[:property_id])
      end
      render json: option_properties
    end

    def create
      option_property = OptionProperty.new(option_property_params)
      option_property.decision_aid = @decision_aid
      authorize option_property

      if option_property.save
        render json: option_property
      else
        render json: { errors: option_property.errors.full_messages }, status: 422
      end

    end

    def update
      option_property = OptionProperty.find(params[:id])
      authorize option_property

      if option_property.update(option_property_params)
        render json: option_property
      else
        render json: { errors: option_property.errors.full_messages }, status: 422
      end
      
    end

    def destroy
      option_property = OptionProperty.find(params[:id])
      authorize option_property

      if option_property.destroy
        render json: { message: "removed" }, status: :ok
      else
        render json: { errors: option_property.errors.full_messages }, status: 422
      end
    end

    def preview
      option_properties = OptionPropertyPolicy::Scope.new(current_user, OptionProperty, @decision_aid).resolve
      render json: option_properties, each_serializer: OptionPropertyPreviewSerializer
    end

    def update_bulk
      updated_option_property_params_hash = bulk_option_property_params[:option_properties].select {|op| op.has_key?("id")}.map {|op| [op[:id].to_s, op]}.to_h
      new_option_property_params = bulk_option_property_params[:option_properties].select{|op| !op.has_key?("id")}
      ops = OptionProperty.where(id: updated_option_property_params_hash.keys)
      ops.each {|op| authorize op}
      final_props = []
      begin
        OptionProperty.transaction do
          updated_option_props = OptionProperty.bulk_update_option_properties(updated_option_property_params_hash, ops)
          created_option_props = OptionProperty.bulk_create_option_properties(new_option_property_params, @decision_aid.id)
          final_props = updated_option_props.concat created_option_props
        end
        render json: final_props
      rescue => error
        render json: { errors: {option_properties: [{"#{error.class}" => error.message}]}}, status: 422
      end
    end

    private

    def bulk_option_property_params
      params[:option_properties] ||= [] if params.has_key?(:option_properties)
      params.permit(option_properties: [:short_label, :id, :ranking_type, :information, :option_id, :property_id, :decision_aid_id, :ranking, :button_label])
    end

    def option_property_params
      params.require(:option_property).permit(:short_label, :ranking_type, :information, :option_id, :property_id, :ranking, :button_label)
    end

    def find_decision_aid
      @decision_aid = DecisionAid.find params[:decision_aid_id]
    end
  end
end