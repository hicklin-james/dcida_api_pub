class CreateBwQuestionSetResponses < ActiveRecord::Migration[4.2]
  def change
    create_table :bw_question_set_responses do |t|
      t.integer :question_set
      t.integer :property_level_ids, array: true
      t.belongs_to :decision_aid
      t.timestamps null: false
    end
  end
end
