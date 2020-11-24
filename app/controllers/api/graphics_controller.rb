module Api
  class GraphicsController < ApplicationController
    before_action :doorkeeper_authorize!
    before_action :authenticate!
    before_action :find_decision_aid

    def index
      graphics = GraphicPolicy::Scope.new(current_user, Graphic, @decision_aid).resolve
        .includes(:graphic_data)
        .order(:created_at => :asc)
 
      # use proper serializer for each subclass
      data = graphics.map {|gr|
        klass = "#{gr.actable_type}Serializer".constantize
        s = klass.new(gr.specific, parent_obj: gr)
        adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
        adapter
      }

      render json: {graphics: data}
    end

    def create
      klass = graphics_params[:actable_type].constantize
      params_to_use = (if klass == AnimatedIconArrayGraphic then animated_icon_array_graphic_params else graphics_params end)
      graphic = klass.new(params_to_use)
      graphic.decision_aid_id = @decision_aid.id
      authorize graphic

      if graphic.save
        render json: graphic, serializer: "#{klass}Serializer".constantize, parent_obj: graphic, root: "graphic"
      else
        render json: { errors: graphic.errors.full_messages }, status: 422
      end

    end

    def update
      klass = graphics_params[:actable_type].constantize
      graphic = klass.find(params[:id])
      authorize graphic

      params_to_use = (if klass == AnimatedIconArrayGraphic then animated_icon_array_graphic_params else graphics_params end)

      if graphic.update(params_to_use)
        render json: graphic, serializer: "#{klass}Serializer".constantize, parent_obj: graphic, root: "graphic"
      else
        render json: { errors: graphic.errors.full_messages }, status: 422
      end
    end

    def destroy
      klass = params[:actable_type].constantize
      graphic = klass.find(params[:id])
      authorize graphic

      if graphic.destroy
        render json: { message: "removed" }, status: :ok
      else
        render json: { errors: graphic.errors.full_messages }, status: 422
      end
    end

    private

    def graphic_data_params
      [ :id, :graphic_id, :animated_icon_array_graphic_stage_id, :value, :label, :color, :sub_value, :sub_value_type, :value_type, :_destroy, :graphic_data_order ]
    end

    def animated_icon_array_graphic_stages_params
      [ :animated_icon_array_graphic_id, :id, :_destroy, :total_n, :general_label, :seperate_values, :graphic_stage_order, :graphic_data_attributes => graphic_data_params ]
    end

    def animated_icon_array_graphic_params
      params.require(:graphic).permit(:id, :title, :selected_index, :selected_index_type, :actable_type, :max_value, :num_per_row,
        :min_value, :chart_title, :y_label, :x_label, :indicators_above, :default_stage,
        :graphic_data_attributes => graphic_data_params, 
        :animated_icon_array_graphic_stages_attributes => animated_icon_array_graphic_stages_params)
    end

    def graphics_params
      params.require(:graphic).permit(:id, :title, :selected_index, :selected_index_type, :actable_type, :max_value, :num_per_row,
        :min_value, :chart_title, :y_label, :x_label,
        :graphic_data_attributes => graphic_data_params)
    end

    def find_decision_aid
       @decision_aid = DecisionAid.find params[:decision_aid_id]
    end

  end
end