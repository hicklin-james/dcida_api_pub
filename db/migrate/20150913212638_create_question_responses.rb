class CreateQuestionResponses < ActiveRecord::Migration[4.2]
  def change
    create_table :question_responses do |t|

      t.belongs_to :question, null: false
      t.belongs_to :decision_aid, null: false
      t.string :question_response_value
      t.boolean :is_correct_value
      t.integer :order, null: false

      t.userstamps
      t.timestamps null: false
    end
  end
end
