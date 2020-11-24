module Api
  class DceQuestionSetsController < ApplicationController
    before_action :doorkeeper_authorize!
    before_action :authenticate!
    before_action :find_decision_aid

    def index
      dce_question_sets = DceQuestionSetPolicy::Scope.new(current_user, DceQuestionSet, @decision_aid).resolve
      render json: dce_question_sets, each_serializer: DceQuestionSetSerializer
    end

    def update_bulk
      begin
        dce_question_set_ids = dce_question_set_bulk_attibutes[:items].map{|qs| qs[:id]}
        indexed_dce_question_sets = dce_question_set_bulk_attibutes[:items].index_by{|qs| qs[:id]}
        updated_question_sets = DceQuestionSet.where(id: dce_question_set_ids).includes(:decision_aid)
        updated_sql_sets = []
        updated_question_sets.each do |op| 
          authorize op
          op.question_title = indexed_dce_question_sets[op.id][:question_title]
          updated_sql_sets << "(#{op.id.to_s},'#{op.question_title}')"
        end

        update_sql = "UPDATE dce_question_sets AS t SET 
                          question_title = c.question_title,
                          updated_at = now()
                        FROM (VALUES
                          #{updated_sql_sets.join(',')}
                        ) AS
                        c(id, question_title) WHERE c.id = t.id"

        ActiveRecord::Base.connection.execute(update_sql)

        render json: updated_question_sets, each_serializer: DceQuestionSetSerializer
      rescue => error
        render json: { errors: {dce_question_sets: [{"#{error.class}" => error.message}]}}, status: 400
      end
    end

    private

    def dce_question_set_bulk_attibutes
      params.require(:dce_question_sets).permit(items: [:id, :question_title])
    end

    def find_decision_aid
      @decision_aid = DecisionAid.find params[:decision_aid_id]
    end
  end
end