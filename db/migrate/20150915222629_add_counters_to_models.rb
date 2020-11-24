class AddCountersToModels < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :options_count, :integer, :null => false, :default => 0
    add_column :decision_aids, :properties_count, :integer, :null => false, :default => 0
    add_column :decision_aids, :option_properties_count, :integer, :null => false, :default => 0
    add_column :decision_aids, :demographic_questions_count, :integer, :null => false, :default => 0
    add_column :decision_aids, :quiz_questions_count, :integer, :null => false, :default => 0
    add_column :decision_aids, :question_responses_count, :integer, :null => false, :default => 0
  end
end
