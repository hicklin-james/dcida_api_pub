module Api
  class LatentClassesController < ApplicationController
    before_action :doorkeeper_authorize!
    before_action :authenticate!
    before_action :find_decision_aid

    def show
      latent_class = LatentClass.includes(:decision_aid).find(params[:id])
      authorize latent_class
      render json: latent_class
    end

    def index
      latent_classes = LatentClassPolicy::Scope.new(current_user, LatentClass, @decision_aid).resolve
      render json: latent_classes, each_serializer: LatentClassSerializer
    end

    def create
      latent_class = LatentClass.new(latent_class_params)
      latent_class.decision_aid = @decision_aid
      authorize latent_class

      if latent_class.save
        render json: latent_class, serializer: LatentClassSerializer
      else
        render json: { errors: latent_class.errors.full_messages }, status: 422
      end
    end

    def update
      latent_class = LatentClass.find(params[:id])
      authorize latent_class

      if latent_class.update(latent_class_params)
        render json: latent_class, serializer: LatentClassSerializer
      else
        render json: { errors: latent_class.errors.full_messages }, status: 422
      end
      
    end

    def create_and_update_and_delete_bulk
      #puts "Starting in create_and_update_and_delete_bulk"
      LatentClass.transaction do
        begin
          lcs_to_return = []

          #puts "Filtering new latent classes"
          new_latent_classes = params[:latent_classes].select{|lc| lc[:id].nil? }
          #puts "Filtering destroyed_latent_classes"
          destroyed_latent_classes = params[:latent_classes].select{|lc| lc[:_destroy] }
          #puts "Filtering updated_latent_classes"
          updated_latent_classes = params[:latent_classes].select{|lc| lc[:id] && !lc[:_destroy] }

          #puts new_latent_classes.inspect
          #puts destroyed_latent_classes.inspect
          #puts updated_latent_classes.inspect

          # first destroy existing latent classes
          destroyed_latent_class_ids = destroyed_latent_classes.map {|lc| lc[:id] }
          if destroyed_latent_class_ids.length > 0
            if destroyed_latent_class_ids.length > 0
              LatentClass.where(id: destroyed_latent_class_ids).destroy_all
            end
          end

          # now update existing latent classes
          updated_latent_class_ids = updated_latent_classes.map {|lc| lc[:id] }
          #puts updated_latent_class_ids
          if updated_latent_class_ids.length > 0
            updated_latent_class_objects = LatentClass.where(id: updated_latent_class_ids).index_by(&:id)
            updated_latent_classes.each do |ulc|
              latent_class = updated_latent_class_objects[ulc[:id]]
              ps = ActionController::Parameters.new({latent_class: ulc})
              latent_class.update!(bulk_latent_class_params(ps))
              lcs_to_return << latent_class
            end
          end

          if new_latent_classes.length > 0
            # finally, create new latent classes
            new_latent_classes.each do |ulc|
              ps = ActionController::Parameters.new({latent_class: ulc})
              lcs_to_return << LatentClass.create!(bulk_latent_class_params(ps))
            end
          end

          render json: lcs_to_return, each_serializer: LatentClassSerializer
        rescue StandardError => e
          #puts e.inspect
          render json: {errors: ["Something bad happened"]}, status: 422
        end
      end
    end

    def destroy
      latent_class = LatentClass.find(params[:id])
      authorize latent_class

      if latent_class.destroy
        render json: { message: "removed" }, status: :ok
      else
        render json: { errors: latent_class.errors.full_messages }, status: 422
      end
    end

    private

    def latent_class_options_attributes
      [:option_id, :weight, :latent_class_id, :id]
    end

    def latent_class_properties_attributes
      [:property_id, :weight, :latent_class_id, :id]
    end

    def latent_class_bulk_params
      params.require(:latent_classes).permit()
    end

    def bulk_latent_class_params(p)
      p.require(:latent_class).permit(:class_order, :decision_aid_id,
        :latent_class_options_attributes => latent_class_options_attributes,
        :latent_class_properties_attributes => latent_class_properties_attributes)
    end

    def find_decision_aid
      @decision_aid = DecisionAid.find params[:decision_aid_id]
    end
  end
end