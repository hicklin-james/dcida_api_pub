module Api
  class DecisionAidUserResponsesController < ApplicationController
    before_action :find_decision_aid_user
    before_action :check_user_session

    def index
      question_type = params[:question_type] if params.has_key?(:question_type)
      decision_aid_user_responses = DecisionAidUserResponsePolicy::Scope.new(DecisionAidUserResponse, @decision_aid_user).resolve
      if question_type
        decision_aid_user_responses = decision_aid_user_responses.joins(:question)
                                                                 .where("questions.question_type = ?", Question.question_types[question_type])
                                                                 .references(:question)
      end
      
      question_ids = params[:question_ids] if params.has_key?(:question_ids)
      if question_ids
        decision_aid_user_responses = decision_aid_user_responses
          .where(question_id: question_ids)
      end

      render json: decision_aid_user_responses
    end

    def show
      daur = DecisionAidUserResponse.find(daur.id)
      authorize daur
      render json: daur
    end

    def create
      daur = DecisionAidUserResponse.new(response_params)
      daur.decision_aid_user_id = @decision_aid_user.id
      authorize daur

      section = if params[:question_type] == "demographic" then "about" else "quiz" end

      q = Question.find(daur.question_id)

      if daur.save
        submitted_question_ids = [daur.question_id]
        
        reliant_questions = @decision_aid.questions
          .where(hidden: true, remote_data_source: false)
          .includes(:question_responses)
          .get_related_hidden_questions(submitted_question_ids)
          .to_a.uniq

        while true
          curr_reliant_question_ids = reliant_questions.map(&:id)
          submitted_question_ids = submitted_question_ids.concat(curr_reliant_question_ids).uniq
          more_questions =  @decision_aid.questions
            .where(hidden: true, remote_data_source: false)
            .where.not(id: curr_reliant_question_ids)
            .includes(:question_responses)
            .get_related_hidden_questions(submitted_question_ids)
            .to_a.uniq
          reliant_questions.concat more_questions
          if more_questions.length == 0
            break
          end
        end

        Question.batch_create_and_update_hidden_responses(reliant_questions, @decision_aid_user)

        rdts = Question.get_remote_data_targets(submitted_question_ids).pluck(:id)
        if rdts.length > 0
          DataTargetExportWorker.perform_async(rdts, @decision_aid_user.id)
        end

        response_hash = Hash.new
        response_hash[q.id] = daur
        r = qp.get_next_question_page(@decision_aid_user, [q], response_hash, section)
        st = @decision_aid_user.progress_tracker.section_trackers.find_by(:page => SectionTracker.pages[(q.question_type == "demographic" ? :about : :quiz)])

        nextq = r[:question]

        DecisionAidUserSkipResult.create_or_update_or_delete(@decision_aid_user, q.question_page_id, r[:skipTo], r[:question])

        render json: daur, serializer: DecisionAidUserResponseSerializer, skip_to: r[:skipTo], next_q: nextq, url_to_use: r[:url_to_use], decision_aid_user: @decision_aid_user, meta: {next_question: nextq}
      else
        render json: { errors: daur.errors.full_messages }, status: 422
      end
    end

    def create_or_update_radio_from_chatbot
      begin
        q = Question.find(params["question_id"])
        response = q.question_responses.find_by(question_response_value: params["question_response_value"])

        #puts "Question id: <#{q.id}> Question response id: <#{response_id}>"

        raise "No response with question_response_value <#{params['question_response_value']} found." if !response

        daur = DecisionAidUserResponse.find_by(question_id: q.id, decision_aid_user_id: @decision_aid_user.id)
        if daur
          authorize daur
          daur.update_attributes!(:question_response_id => response.id)
        else
          daur = DecisionAidUserResponse.new
          daur.question_id = q.id
          daur.question_response_id = response.id
          daur.decision_aid_user_id = @decision_aid_user.id
          authorize daur
          daur.save!
        end

        submitted_question_ids = [daur.question_id]
        
        reliant_questions = @decision_aid.questions
          .where(hidden: true, remote_data_source: false)
          .includes(:question_responses)
          .get_related_hidden_questions(submitted_question_ids)
          .to_a.uniq

        while true
          curr_reliant_question_ids = reliant_questions.map(&:id)
          submitted_question_ids = submitted_question_ids.concat(curr_reliant_question_ids).uniq
          more_questions =  @decision_aid.questions
            .where(hidden: true, remote_data_source: false)
            .where.not(id: curr_reliant_question_ids)
            .includes(:question_responses)
            .get_related_hidden_questions(submitted_question_ids)
            .to_a.uniq
          reliant_questions.concat more_questions
          if more_questions.length == 0
            break
          end
        end

        rdts = Question.get_remote_data_targets(submitted_question_ids).pluck(:id)
        if rdts.length > 0
          DataTargetExportWorker.perform_async(rdts, @decision_aid_user.id)
        end

        Question.batch_create_and_update_hidden_responses(reliant_questions, @decision_aid_user)

        render json: {'Save' => 'Successful'}, status: 200
      rescue => error
        render json: { errors: [error.message]}, status: 400
      end
    end

    def update
      daur = DecisionAidUserResponse.find(params[:id])
      authorize daur

      section = if params[:question_type] == "demographic" then "about" else "quiz" end

      q = Question.find(daur.question_id)
      qp = QuestionPage.find(q.question_page_id)

      submitted_question_ids = [daur.question_id]
      
      if daur.update(response_params)
        reliant_questions = @decision_aid.questions
          .where(hidden: true, remote_data_source: false)
          .includes(:question_responses)
          .get_related_hidden_questions(submitted_question_ids)
          .to_a.uniq

        while true
          curr_reliant_question_ids = reliant_questions.map(&:id)
          submitted_question_ids = submitted_question_ids.concat(curr_reliant_question_ids).uniq
          more_questions =  @decision_aid.questions
            .where(hidden: true, remote_data_source: false)
            .where.not(id: curr_reliant_question_ids)
            .includes(:question_responses)
            .get_related_hidden_questions(submitted_question_ids)
            .to_a.uniq
          reliant_questions.concat more_questions
          if more_questions.length == 0
            break
          end
        end
        
        Question.batch_create_and_update_hidden_responses(reliant_questions, @decision_aid_user)

        rdts = Question.get_remote_data_targets(submitted_question_ids).pluck(:id)
        if rdts.length > 0
          DataTargetExportWorker.perform_async(rdts, @decision_aid_user.id)
        end

        #questions_in_page = submitted_questions.select{|q| q.question_page_id == qp.id }
        #indexed_responses_for_questions = responses.select{|r| questions_in_page.any?{|q| q.id == r.question_id}}.index_by(&:question_id)
        response_hash = Hash.new
        response_hash[q.id] = daur
        r = qp.get_next_question_page(@decision_aid_user, [q], response_hash, section)
        st = @decision_aid_user.progress_tracker.section_trackers.find_by(:page => SectionTracker.pages[(q.question_type == "demographic" ? :about : :quiz)])
        #r = qp.get_next_question(@decision_aid_user, daur, @decision_aid)
        nextq = r[:question]

        DecisionAidUserSkipResult.create_or_update_or_delete(@decision_aid_user, qp.id, r[:skipTo], r[:question])
        
        render json: daur, serializer: DecisionAidUserResponseSerializer, next_q: nextq, url_to_use: r[:url_to_use], decision_aid_user: @decision_aid_user, meta: {next_question: nextq}
      else
        render json: { errors: daur.errors.full_messages }, status: 422
      end
    end

    def create_and_update_bulk
      if !params.has_key?(:decision_aid_user_responses)
        render json: { errors: {decision_aid_user_responses: [{"Exceptions::MissingParams" => 'ParamMissing'}]}}, status: 400
      else
        section = if params[:question_type] == "demographic" then "about" else "quiz" end

        # special case for empty responses... need to get page elsewhere
        # since we normally get it off the questions
        if !params[:decision_aid_user_responses]
          qp = QuestionPage.find_by(id: params[:question_page_id])
          if qp
            r = qp.get_next_question_page(@decision_aid_user, [], [], section)
            nextqp = r[:question_page]
            render json: [], each_serializer: DecisionAidUserResponseSerializer, next_qp: nextqp, url_to_use: r[:url_to_use], decision_aid_user: @decision_aid_user, meta: {next_question_page: nextqp}
          else
            render json: { errors: ["Something catastrophic happened!!!"]}, status: 400
          end
          return
        end

        updated_responses = params[:decision_aid_user_responses].select{ |daur| !daur["id"].nil? }
        created_responses = params[:decision_aid_user_responses].select{ |daur| daur["id"].nil? }

        responses = []
        ids = updated_responses.map{ |daur| daur["id"] }

        # resp = params[:decision_aid_user_responses].find{ |daur| daur["question_response_id"].nil?}
        # grid_question_id = resp["question_id"] if resp
        # q = nil
        # if !grid_question_id.blank?
        #   q = Question.find(grid_question_id)
        # end

        submitted_questions = Question
          .where(id: params[:decision_aid_user_responses].map{ |daur|  daur["question_id"] })
          .ordered

        submitted_question_pages = QuestionPage.where(
          decision_aid_id: @decision_aid.id,
          id: submitted_questions.reject{|q| q.question_id }.map(&:question_page_id)
        ).includes(:skip_logic_targets => :skip_logic_conditions).ordered

        nextqp = nil
        r = Hash.new
        submitted_question_ids = []

        begin
          ActiveRecord::Base.transaction do
            decision_aid_user_responses = DecisionAidUserResponse.where(id: ids)
            raise Exceptions::InvalidParams, "InvalidId" if decision_aid_user_responses.length != ids.length
            decision_aid_user_responses.each do |daur|
              updated_params = params[:decision_aid_user_responses].find { |daur_p| daur_p["id"].to_i == daur.id }

              daur.response_value = updated_params["response_value"]
              daur.question_response_id = updated_params["question_response_id"]
              daur.number_response_value = updated_params["number_response_value"]
              daur.option_id = updated_params["option_id"]
              daur.json_response_value = updated_params["json_response_value"]
              daur.selected_unit = updated_params["selected_unit"]

              if daur.changed?
                daur.save!
              end
              responses.push daur
            end
            
            created_responses.each do |daur_params|
              responses.push DecisionAidUserResponse.create!(question_response_id: daur_params["question_response_id"],
                                             response_value: daur_params["response_value"],
                                             question_id: daur_params["question_id"],
                                             number_response_value: daur_params["number_response_value"],
                                             decision_aid_user_id: daur_params["decision_aid_user_id"],
                                             option_id: daur_params["option_id"],
                                             json_response_value: daur_params["json_response_value"])
            end

            #resp = responses.find {|r| r.question_id == grid_question_id.to_i}

            # update the hidden questions that aren't from a remote data source
            submitted_question_ids = submitted_questions.map(&:id)

            reliant_questions = @decision_aid.questions
              .where(hidden: true, remote_data_source: false)
              .includes(:question_responses)
              .get_related_hidden_questions(submitted_question_ids)
              .to_a.uniq

            while true
              curr_reliant_question_ids = reliant_questions.map(&:id)
              submitted_question_ids = submitted_question_ids.concat(curr_reliant_question_ids).uniq
              more_questions =  @decision_aid.questions
                .where(hidden: true, remote_data_source: false)
                .where.not(id: curr_reliant_question_ids)
                .includes(:question_responses)
                .get_related_hidden_questions(submitted_question_ids)
                .to_a.uniq
              reliant_questions.concat more_questions
              if more_questions.length == 0
                break
              end
            end

            Question.batch_create_and_update_hidden_responses(reliant_questions, @decision_aid_user) if reliant_questions.length > 0

            # From HEAD - not sure if needed...
            # if q
            #   r = q.get_next_question(@decision_aid_user, resp, @decision_aid)
            #   st = @decision_aid_user.progress_tracker.section_trackers.find_by(:page => SectionTracker.pages[(q.question_type == "demographic" ? :about : :quiz)])
            #   nextq = r[:question]
            #   DecisionAidUserSkipResult.create_or_update_or_delete(@decision_aid_user, q.id, r[:skipTo], r[:question])
            # end

            submitted_question_pages.each_with_index do |qp, ind|
              questions_in_page = submitted_questions.select{|q| q.question_page_id == qp.id }
              indexed_responses_for_questions = responses.select{|r| questions_in_page.any?{|q| q.id == r.question_id}}.index_by(&:question_id)
              r = qp.get_next_question_page(@decision_aid_user, questions_in_page, indexed_responses_for_questions, section)
              nextqp = r[:question_page]
              DecisionAidUserSkipResult.create_or_update_or_delete(@decision_aid_user, qp.id, r[:skipTo], r[:question_page])
              break if r[:skipTo]
            end
          end

          # must be outside the transaction, otherwise sidekiq may not be using committed data
          rdts = Question.get_remote_data_targets(submitted_question_ids).pluck(:id)
          if rdts.length > 0
            DataTargetExportWorker.perform_async(rdts, @decision_aid_user.id)
          end

          render json: responses, each_serializer: DecisionAidUserResponseSerializer, skip_to: r[:skipTo], next_qp: nextqp, url_to_use: r[:url_to_use], decision_aid_user: @decision_aid_user, meta: {next_question_page: nextqp}
        rescue => error
          render json: { errors: [error.message]}, status: 400
        end
      end
    end

    private

    def response_params
      params.require(:decision_aid_user_response).permit(:id, :question_response_id, :response_value, :number_response_value, :option_id, :question_id, :selected_unit).tap do |whitelisted|
        whitelisted[:json_response_value] = params[:decision_aid_user_response][:json_response_value].permit!
      end
    end

    def find_decision_aid_user
      @decision_aid_user = DecisionAidUser.includes(:decision_aid_user_responses).find(params[:decision_aid_user_id])
      @decision_aid = @decision_aid_user.decision_aid
    end

    def pundit_user
      current_decision_aid_user
    end
  end
end