class ModifyDecisionAidUserSkipResultTable < ActiveRecord::Migration[4.2]
  def change
    rename_column :decision_aid_user_skip_results, :target_question_id, :target_question_page_id
  end
end
