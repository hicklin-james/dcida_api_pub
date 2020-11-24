class ChangeSummaryPanelsQuestionIdsDefault < ActiveRecord::Migration[4.2]
  def change
    change_column_default :summary_panels, :question_ids, []
  end
end
