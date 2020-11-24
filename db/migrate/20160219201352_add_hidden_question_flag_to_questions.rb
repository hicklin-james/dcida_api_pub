class AddHiddenQuestionFlagToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :hidden, :boolean, default: false
  end
end
