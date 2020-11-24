module Api
  class StaticPagesController < ApplicationController
    before_action :doorkeeper_authorize!
    before_action :authenticate!
    before_action :find_decision_aid

    def show
      static_page = StaticPage.includes(:decision_aid).find(params[:id])
      authorize static_page
      render json: static_page
    end

    def index
      static_pages = StaticPagePolicy::Scope.new(current_user, StaticPage, @decision_aid).resolve
      render json: static_pages, each_serializer: StaticPageSerializer
    end

    def create
      static_page = StaticPage.new(static_page_params)
      static_page.decision_aid = @decision_aid
      static_page.initialize_order(@decision_aid.static_pages_count)
      authorize static_page

      if static_page.save
        render json: static_page, serializer: StaticPageSerializer
      else
        render json: { errors: static_page.errors.full_messages }, status: 422
      end
    end

    def update
      static_page = StaticPage.find(params[:id])
      authorize static_page

      if static_page.update(static_page_params)
        render json: static_page, serializer: StaticPageSerializer
      else
        render json: { errors: static_page.errors.full_messages }, status: 422
      end
      
    end

    def destroy
      static_page = StaticPage.find(params[:id])
      authorize static_page

      if static_page.destroy
        render json: { message: "removed" }, status: :ok
      else
        render json: { errors: static_page.errors.full_messages }, status: 422
      end
    end

    def update_order
      static_page = StaticPage.find(params[:id])
      authorize static_page

      static_page.change_order(static_page_params[:static_page_order])
      render json: static_page, serializer: StaticPageSerializer
    end

    private

    def static_page_params
      params.require(:static_page).permit(:page_text, :page_title, :static_page_order, :page_slug)
    end

    def find_decision_aid
      @decision_aid = DecisionAid.find params[:decision_aid_id]
    end
  end
end