class CreateDecisionAidUserResponses < ActiveRecord::Migration[4.2]
  def change
    create_table :decision_aid_user_responses do |t|
      t.integer :question_response_id
      t.text :response_value
      t.integer :question_id, null: false
      t.integer :decision_aid_user_id, null: false

      t.timestamps null: false
    end
  end
end
