module Api
  class NavLinksController < ApplicationController
    before_action :doorkeeper_authorize!
    before_action :authenticate!
    before_action :find_decision_aid

    def show
      nav_link = NavLink.includes(:decision_aid).find(params[:id])
      authorize nav_link
      render json: nav_link
    end

    def index
      nav_links = NavLinkPolicy::Scope.new(current_user, NavLink, @decision_aid).resolve
      render json: nav_links, each_serializer: NavLinkSerializer
    end

    def create
      nav_link = NavLink.new(nav_link_params)
      nav_link.decision_aid = @decision_aid
      nav_link.initialize_order(@decision_aid.nav_links_count)
      authorize nav_link

      if nav_link.save
        render json: nav_link, serializer: NavLinkSerializer
      else
        render json: { errors: nav_link.errors.full_messages }, status: 422
      end
    end

    def update
      nav_link = NavLink.find(params[:id])
      authorize nav_link

      if nav_link.update(nav_link_params)
        render json: nav_link, serializer: NavLinkSerializer
      else
        render json: { errors: nav_link.errors.full_messages }, status: 422
      end
      
    end

    def destroy
      nav_link = NavLink.find(params[:id])
      authorize nav_link

      if nav_link.destroy
        render json: { message: "removed" }, status: :ok
      else
        render json: { errors: nav_link.errors.full_messages }, status: 422
      end
    end

    def update_order
      nav_link = NavLink.find(params[:id])
      authorize nav_link

      nav_link.change_order(nav_link_params[:nav_link_order])
      render json: nav_link, serializer: NavLinkSerializer
    end

    private

    def nav_link_params
      params.require(:nav_link).permit(:link_text, :link_href, :link_location, :nav_link_order)
    end

    def find_decision_aid
      @decision_aid = DecisionAid.find params[:decision_aid_id]
    end
  end
end