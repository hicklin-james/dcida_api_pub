class AddBwStuffToDecisionAid < ActiveRecord::Migration[4.2]
  def up
    add_attachment :decision_aids, :bw_design_file
    add_column :decision_aids, :bw_question_set_responses_count, :integer, :null => false, :default => 0
  end

  def down
    remove_attachment :decision_aids, :bw_design_file
    remove_column :decision_aids, :bw_question_set_responses_count
  end
end
