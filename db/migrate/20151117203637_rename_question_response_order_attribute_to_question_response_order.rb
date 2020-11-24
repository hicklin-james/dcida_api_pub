class RenameQuestionResponseOrderAttributeToQuestionResponseOrder < ActiveRecord::Migration[4.2]
  def change
    rename_column :question_responses, :order, :question_response_order
  end
end
