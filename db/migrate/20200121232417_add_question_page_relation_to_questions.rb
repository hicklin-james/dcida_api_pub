class AddQuestionPageRelationToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :question_page_id, :integer
  end
end
