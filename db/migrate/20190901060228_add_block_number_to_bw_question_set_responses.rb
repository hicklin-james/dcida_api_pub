class AddBlockNumberToBwQuestionSetResponses < ActiveRecord::Migration[4.2]
  def change
  	add_column :bw_question_set_responses, :block_number, :integer, null: false, default: 1
  end
end
