class ChangeQuestionIsCorrectValueToIsTextResponse < ActiveRecord::Migration[4.2]
  def change
    rename_column :question_responses, :is_correct_value, :is_text_response
  end
end
