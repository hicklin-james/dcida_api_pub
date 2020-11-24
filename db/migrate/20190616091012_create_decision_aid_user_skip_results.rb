class CreateDecisionAidUserSkipResults < ActiveRecord::Migration[4.2]
  def change
    create_table :decision_aid_user_skip_results do |t|
      t.belongs_to :source_question, null: false
      t.belongs_to :decision_aid_user, null: false

      t.integer :target_type, null: false
      t.integer :target_question_id

      t.timestamps null: false
    end
  end
end
