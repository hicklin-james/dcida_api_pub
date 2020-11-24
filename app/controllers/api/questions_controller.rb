module Api
  class QuestionsController < ApplicationController
    before_action :doorkeeper_authorize!
    before_action :authenticate!
    before_action :find_decision_aid

    def index
      questions = QuestionPolicy::Scope.new(current_user, Question, @decision_aid).resolve.order(:question_type).ordered
      if params.has_key?(:question_type)
        question_types = params[:question_type].split(',').map {|qt| Question.question_types[qt]}
        questions = questions.where(question_type: question_types)
      end
      if params.has_key?(:question_response_type)
        response_types = params[:question_response_type].split(",").map{|qrt| Question.question_response_types[qrt]}
        questions = questions.where(question_response_type: response_types)
      end
      if params.has_key?(:include_hidden)
        questions = questions.where(hidden: params[:include_hidden])
      end
      if params.has_key?(:flatten) and params[:flatten] == "true"
        questions = questions.unscope(where: :question_id)
      end
      if params.has_key?(:include_responses) and params[:include_responses] == "true"
        questions = questions.includes(:question_responses, :my_sql_question_params, :grid_questions => [:question_responses, :my_sql_question_params])
        render json: questions, skip_skip_logic_targets: true
      else
        render json: questions, each_serializer: QuestionListSerializer
      end
    end

    def show
      question = Question.includes(:question_responses, :grid_questions => [:question_responses]).find(params[:id])
      authorize question
      render json: question
    end

    def create
      question = Question.new(question_params)
      question.lookup_table = params[:question][:lookup_table] if params.has_key?(:question) and params[:question].has_key?(:lookup_table)
      question.decision_aid_id = @decision_aid.id
      question.initialize_order(question.order_scope.count)
      authorize question

      if question.save
        render json: question
      else
        render json: { errors: question.errors.full_messages }, status: 422
      end
    end

    def clone
      question = Question.find(params[:id])
      authorize question
      
      r = question.clone_question(@decision_aid)
      if r[:error]
        render json: {errors: r.error}, status: 422
      else
        render json: r[:question]
      end
    end

    def update
      question = Question.find(params[:id])
      question.lookup_table = params[:question][:lookup_table] if params.has_key?(:question) and params[:question].has_key?(:lookup_table)
      authorize question

      if question.update(question_params)
        render json: question
      else
        render json: { errors: question.errors.full_messages }, status: 422
      end
    end

    def destroy
      question = Question.find(params[:id])
      authorize question

      if question.destroy
        render json: { message: "removed" }, status: :ok
      else
        render json: { errors: question.errors.full_messages }, status: 422
      end
    end

    def preview
      questions = QuestionPolicy::Scope.new(current_user, Question, @decision_aid).resolve.ordered.where(hidden: false)
      if params.has_key?(:question_type)
        questions = questions.where(question_type: Question.question_types[params[:question_type]])
      end
      render json: questions, each_serializer: QuestionPreviewSerializer, status: 200
    end

    def update_order
      question = Question.find(params[:id])
      authorize question

      question.change_order(question_params[:question_order])
      render json: question
    end

    def move_question_to_page
      question = Question.find(params[:id])
      authorize question

      question.remove_from_order

      question.question_page_id = question_params[:question_page_id]
      question.initialize_order(question.order_scope.count)
      question.save!

      question.change_order(question_params[:question_order])
      
      render json: question
    end

    def test_redcap_question
      redcap_service = RedcapService.new(@decision_aid)
      r = redcap_service.test_question(params[:redcap_question_variable])
      if r.has_key?(:body)
        render json: r[:body], serializer: nil
      else
        render json: {errors: [r[:error]]}, status: 400
      end
    end

    private

    def question_order_params
      params.require(:questions).permit(:question_list => [:id, :question_order])
    end

    def skip_logic_attributes
      [ :id, :question_response_id, :decision_aid_id, :target_entity, :skip_question_page_id, :skip_page_url,
        :skip_logic_target_order, :_destroy,
        :skip_logic_conditions_attributes => [:id, :skip_logic_target_id, :decision_aid_id, :condition_entity, :entity_lookup,
          :entity_value_key, :value_to_match, :logical_operator, :skip_logic_condition_order, :_destroy]
      ]
    end

    def question_response_attributes
      [ :question_response_value, :redcap_response_value, :is_text_response, :numeric_value, :decision_aid_id, :id, 
        :question_response_order, :_destroy, :popup_information, :include_popup_information,
        :skip_logic_targets_attributes => skip_logic_attributes
      ]
    end

    def question_params
      params[:question][:current_treatment_option_ids] = [] if (params.has_key?(:question) and params[:question].has_key?(:current_treatment_option_ids) and params[:question][:current_treatment_option_ids] == nil)
      params[:question][:units_array] = [] if (params.has_key?(:question) and params[:question].has_key?(:units_array) and params[:question][:units_array] == nil)
      # params[:question][:post_question_text] = nil if (params.has_key?(:question) and params[:question][:post_question_text] == nil)
      params.require(:question).permit(:question_text, :sub_decision_id, :question_response_style, :question_order, :question_type, :question_response_type, :hidden, :response_value_calculation,
        :remote_data_source, :remote_data_source_type, :redcap_field_name, :slider_left_label, :slider_right_label, :slider_granularity, :num_decimals_to_round_to, :can_change_response,
        :post_question_text, :slider_midpoint_label, :unit_of_measurement, :side_text, :skippable, :is_exclusive, :randomized_response_order, :min_number, :max_number, :min_chars, :max_chars,
        :remote_data_target, :remote_data_target_type, :backend_identifier, :question_page_id,
        :lookup_table_dimensions => [], :current_treatment_option_ids => [], :units_array => [],
        :question_responses_attributes => question_response_attributes,
        # :skip_logic_targets_attributes => skip_logic_attributes,
        :grid_questions_attributes => [:id, :question_text, :post_question_text, :question_type, :is_exclusive, :question_response_style, :question_order, :question_response_type, :decision_aid_id, :_destroy, 
                                       :remote_data_target, :remote_data_target_type, :redcap_field_name, :remote_data_target, :remote_data_target_type, :backend_identifier, 
                                       :question_responses_attributes => question_response_attributes])
    end

    def find_decision_aid
      @decision_aid = DecisionAid.find params[:decision_aid_id]
    end
    
  end
end