class AddOptionConfirmedToDecisionAidUserDceQuestionSetResponse < ActiveRecord::Migration[4.2]
  def change
  	add_column :decision_aid_user_dce_question_set_responses, :option_confirmed, :boolean
  end
end
