class AddBlockNumberToDceQuestionSetResponse < ActiveRecord::Migration[4.2]
  def change
    add_column :dce_question_set_responses, :block_number, :integer, default: 1, null: false
  end
end
