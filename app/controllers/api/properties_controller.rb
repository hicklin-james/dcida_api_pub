module Api
  class PropertiesController < ApplicationController
    before_action :doorkeeper_authorize!
    before_action :authenticate!
    before_action :find_decision_aid, only: [:create, :clone, :preview, :index]

    def show
      property = Property.find(params[:id])
      authorize property
      render json: property
    end

    def index
      properties = PropertyPolicy::Scope.new(current_user, Property, @decision_aid).resolve.ordered
      render json: properties, each_serializer: PropertyListSerializer
    end

    def create
      property = Property.new(property_params)
      property.decision_aid = @decision_aid
      property.initialize_order(@decision_aid.properties_count)
      authorize property

      if property.save
        render json: property
      else
        render json: { errors: property.errors.full_messages }, status: 422
      end

    end

    def update
      property = Property.find(params[:id])
      authorize property

      if property.update(property_params)
        render json: property
      else
        render json: { errors: property.errors.full_messages }, status: 422
      end
      
    end
 
    def destroy
      property = Property.find(params[:id])
      authorize property

      if property.destroy
        render json: { message: "removed" }, status: :ok
      else
        render json: { errors: property.errors.full_messages }, status: 422
      end
    end

    def clone
      property = Property.find(params[:id])
      authorize property

      r = property.clone_property(@decision_aid)
      if r.has_key?(:property)
        render json: r[:property]
      else
        render json: r[:errors], status: 422
      end
    end

    def preview
      properties = PropertyPolicy::Scope.new(current_user, Property, @decision_aid).resolve.ordered
      render json: properties, each_serializer: PropertyPreviewSerializer
    end

    def update_order
      property = Property.find(params[:id])
      authorize property

      property.change_order(property_params[:property_order])
      render json: property
    end

    private

    def property_params
      params.require(:property).permit(:title, :short_label, :selection_about, :long_about, :property_order,
           :is_property_weighable, :are_option_properties_weighable, :property_group_title, :backend_identifier,
        property_levels_attributes: [:information, :level_id, :decision_aid_id, :property_id, :_destroy, :id])
    end

    def find_decision_aid
      @decision_aid = DecisionAid.find params[:decision_aid_id]
    end
  end
end