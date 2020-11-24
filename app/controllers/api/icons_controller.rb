module Api
  class IconsController < ApplicationController
    before_action :doorkeeper_authorize!
    before_action :authenticate!
    before_action :find_decision_aid

    def index
      icons = IconPolicy::Scope.new(current_user, Icon, @decision_aid).resolve
      if params.has_key?(:icon_type)
        icons = icons.where(icon_type: params[:icon_type])
      end
      
      render json: icons
    end

    def create
      i = Icon.new(decision_aid_id: @decision_aid.id)
      i.url = params[:icon_url]
      i.image = params[:file]
      authorize i
      if i.save
        render json: i
      else
        render json: {errors: i.errors}, status: 500
      end

    end

    def destroy
      i = Icon.find(params[:id])
      authorize i
      begin
        if i.destroy
          render json: { message: "removed" }, status: :ok
        else
          render json: {errors: i.errors}, status: 500
        end
      rescue ActiveRecord::InvalidForeignKey => e
        render json: {errors: "RecordStillReferenced"}, status: 500
      end
    end

    def update_bulk
      params[:icons] ||= [] if params.has_key?(:icons)
      icon_ids = params[:icons].map {|icon| icon[:id]}
      icon_properties = params[:icons].map {|i| [i[:id].to_i, i]}.to_h
      icons = Icon.where(id: icon_ids)
      updated_icons = []
      Icon.transaction do
        icons.each do |icon|
          authorize icon, :update?
          icon.url = icon_properties[icon.id][:url] if icon_properties[icon.id]
          icon.save
        end
      end

      render json: icons
    end

    private

    def find_decision_aid
      @decision_aid = DecisionAid.find params[:decision_aid_id]
    end
  end
end