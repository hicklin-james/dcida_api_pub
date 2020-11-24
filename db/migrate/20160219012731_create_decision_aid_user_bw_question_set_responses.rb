class CreateDecisionAidUserBwQuestionSetResponses < ActiveRecord::Migration[4.2]
  def change
    create_table :decision_aid_user_bw_question_set_responses do |t|
      t.belongs_to :bw_question_set_response
      t.belongs_to :decision_aid_user
      t.integer :question_set
      t.integer :best_property_level_id
      t.integer :worst_property_level_id

      t.timestamps null: false
    end
  end
end
