class AddDecisionAidUserBwQuestionSetResponsesCountToDecisionAidUser < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aid_users, :decision_aid_user_bw_question_set_responses_count, :integer, :null => false, :default => 0
  end
end
