class AddOptionQuestionToSubDecision < ActiveRecord::Migration[4.2]
  def change
    add_column :sub_decisions, :option_question_text, :text
  end
end
