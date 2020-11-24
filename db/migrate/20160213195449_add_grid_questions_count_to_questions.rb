class AddGridQuestionsCountToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :grid_questions_count, :integer, :null => false, :default => 0
  end
end
