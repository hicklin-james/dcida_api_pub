module Api
  class AccordionsController < ApplicationController
    before_action :doorkeeper_authorize!
    before_action :authenticate!
    before_action :find_decision_aid

    def index
      accordions = AccordionPolicy::Scope.new(current_user, Accordion, @decision_aid).resolve
      render json: accordions
    end

    def create
      accordion = Accordion.new(accordion_params)
      accordion.decision_aid_id = @decision_aid.id
      accordion.user_id = current_user.id
      authorize accordion


      accordion.accordion_contents.each do |acc|
        acc.decision_aid_id = @decision_aid.id
      end

      if accordion.save
        render json: accordion
      else
        render json: { errors: accordion.errors.full_messages }, status: 422
      end
    end

    def update
      accordion = Accordion.find(params[:id])
      authorize accordion

      if params.has_key?(:garbage_bin) and params[:garbage_bin]
        AccordionContent::destroy_panels(params[:id], params[:garbage_bin])
      end

      accordion.reload

      if accordion.update!(accordion_params)
        render json: accordion
      else
        render json: { errors: accordion.errors.full_messages }, status: 422
      end
    end

    def destroy
      accordion = Accordion.find(params[:id])
      authorize accordion

      if accordion.destroy
        render json: { message: "removed" }, status: :ok
      else
        render json: { errors: accordion.errors.full_messages }, status: 422
      end
    end

    private

    def accordion_params
      params.require(:accordion).permit(:title, :accordion_contents_attributes => [ :content, :id, :header, :order, :is_open_by_default, :panel_color, :_destroy, :decision_aid_id ])
    end

    def find_decision_aid
       @decision_aid = DecisionAid.find params[:decision_aid_id]
    end
    
  end
end