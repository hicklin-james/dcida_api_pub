class AddDefaultSelectedFlagToDecisionAidUserDceQuestionSetResponse < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aid_user_dce_question_set_responses, :fallback_question_set_id, :integer
  end
end
