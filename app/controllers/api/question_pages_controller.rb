module Api
  class QuestionPagesController < ApplicationController
    before_action :doorkeeper_authorize!
    before_action :authenticate!
    before_action :find_decision_aid, only: [:create, :index]

    def show
      question_page = QuestionPage.find(params[:id])
      authorize question_page
      render json: question_page
    end

    def index
      question_pages = QuestionPagePolicy::Scope.new(current_user, QuestionPage, @decision_aid).resolve.ordered
      if params[:section]
        question_pages = question_pages.where(section: QuestionPage.sections[params[:section]])
      end

      render json: question_pages, each_serializer: QuestionPageSerializer, include_questions: params[:include_questions]
    end

    def create
      question_page = QuestionPage.new(question_page_params)
      question_page.decision_aid = @decision_aid
      question_page.initialize_order(question_page.order_scope.count)
      authorize question_page

      if question_page.save
        render json: question_page, serializer: QuestionPageSerializer, include_questions: true
      else
        render json: { errors: question_page.errors.full_messages }, status: 422
      end

    end

    def update
      question_page = QuestionPage.find(params[:id])
      authorize question_page

      if question_page.update(question_page_params)
        render json: question_page.reload, serializer: QuestionPageSerializer, include_questions: true
      else
        render json: { errors: question_page.errors.full_messages }, status: 422
      end
      
    end
 
    def destroy
      question_page = QuestionPage.find(params[:id])
      authorize question_page

      if question_page.destroy
        render json: { message: "removed" }, status: :ok
      else
        render json: { errors: question_page.errors.full_messages }, status: 422
      end
    end

    def update_order
      question_page = QuestionPage.find(params[:id])
      authorize question_page

      question_page.change_order(question_page_params[:question_page_order])
      render json: question_page
    end

    private

    def skip_logic_attributes
      [ :id, :question_page_id, :decision_aid_id, :target_entity, :skip_question_page_id, :skip_page_url,
        :skip_logic_target_order, :include_query_params, :_destroy,
        :skip_logic_conditions_attributes => [:id, :skip_logic_target_id, :decision_aid_id, :condition_entity, :entity_lookup,
          :entity_value_key, :value_to_match, :logical_operator, :skip_logic_condition_order, :_destroy]
      ]
    end

    def question_page_params
      params.require(:question_page).permit(:section, :question_page_order, :skip_logic_targets_attributes => skip_logic_attributes)
    end

    def find_decision_aid
      @decision_aid = DecisionAid.find params[:decision_aid_id]
    end
  end
end