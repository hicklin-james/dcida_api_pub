module Api
  class IntroPagesController < ApplicationController
    before_action :doorkeeper_authorize!
    before_action :authenticate!
    before_action :find_decision_aid

    def show
      intro_page = IntroPage.includes(:decision_aid).find(params[:id])
      authorize intro_page
      render json: intro_page
    end

    def index
      intro_pages = IntroPagePolicy::Scope.new(current_user, IntroPage, @decision_aid).resolve
      render json: intro_pages, each_serializer: IntroPageSerializer
    end

    def create
      intro_page = IntroPage.new(intro_page_params)
      intro_page.decision_aid = @decision_aid
      authorize intro_page

      if intro_page.save
        render json: intro_page, serializer: IntroPageSerializer
      else
        render json: { errors: intro_page.errors.full_messages }, status: 422
      end
    end

    def update
      intro_page = IntroPage.find(params[:id])
      authorize intro_page

      if intro_page.update(intro_page_params)
        render json: intro_page, serializer: IntroPageSerializer
      else
        render json: { errors: intro_page.errors.full_messages }, status: 422
      end
      
    end

    def destroy
      intro_page = IntroPage.find(params[:id])
      authorize intro_page

      if intro_page.destroy
        render json: { message: "removed" }, status: :ok
      else
        render json: { errors: intro_page.errors.full_messages }, status: 422
      end
    end

    def update_order
      intro_page = IntroPage.find(params[:id])
      authorize intro_page

      intro_page.change_order(intro_page_params[:intro_page_order])
      render json: intro_page, serializer: IntroPageSerializer
    end

    def preview
      intro_pages = IntroPagePolicy::Scope.new(current_user, IntroPage, @decision_aid).resolve.ordered
      render json: intro_pages, each_serializer: IntroPagePreviewSerializer
    end

    private

    def intro_page_params
      params.require(:intro_page).permit(:description, :intro_page_order)
    end

    def find_decision_aid
      @decision_aid = DecisionAid.find params[:decision_aid_id]
    end
  end
end