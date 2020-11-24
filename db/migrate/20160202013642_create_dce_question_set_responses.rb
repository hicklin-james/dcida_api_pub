class CreateDceQuestionSetResponses < ActiveRecord::Migration[4.2]
  def change
    create_table :dce_question_set_responses do |t|
      t.integer :question_set
      t.integer :response_value
      t.json :property_level_hash
      t.belongs_to :decision_aid

      t.timestamps null: false
    end
  end
end
