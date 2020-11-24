class AddQuestionResponsesToOptions < ActiveRecord::Migration[4.2]
  def change
    add_column :options, :question_response_array, :integer, array: true, default: []
  end
end
