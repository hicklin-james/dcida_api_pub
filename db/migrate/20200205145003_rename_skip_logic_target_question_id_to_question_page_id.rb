class RenameSkipLogicTargetQuestionIdToQuestionPageId < ActiveRecord::Migration[4.2]
  def change
    rename_column :skip_logic_targets, :question_id, :question_page_id
    rename_column :decision_aid_user_skip_results, :source_question_id, :source_question_page_id
    add_column :question_pages, :skip_logic_target_count, :integer, :null => false, :default => 0
  end
end
