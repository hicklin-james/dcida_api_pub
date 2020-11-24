class CreateDecisionAidUserDceQuestionSetResponses < ActiveRecord::Migration[4.2]
  def change
    create_table :decision_aid_user_dce_question_set_responses do |t|
      t.belongs_to :dce_question_set_response
      t.belongs_to :decision_aid_user
      t.integer :question_set

      t.timestamps null: false
    end
  end
end
