class AddDceQuestionSetResponseCounterToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :dce_question_set_responses_count, :integer, :null => false, :default => 0
  end
end
