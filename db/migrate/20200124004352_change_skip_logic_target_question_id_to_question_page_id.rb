class ChangeSkipLogicTargetQuestionIdToQuestionPageId < ActiveRecord::Migration[4.2]
  def change
    rename_column :skip_logic_targets, :skip_question_id, :skip_question_page_id
  end
end
