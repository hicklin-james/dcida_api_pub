class AddSideTextFieldToQuestions < ActiveRecord::Migration[4.2]
  def change
  	add_column :questions, :side_text, :text
  	add_column :questions, :side_text_published, :text
  end
end
