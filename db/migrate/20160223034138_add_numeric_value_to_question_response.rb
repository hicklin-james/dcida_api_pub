class AddNumericValueToQuestionResponse < ActiveRecord::Migration[4.2]
  def change
    add_column :question_responses, :numeric_value, :float
  end
end
