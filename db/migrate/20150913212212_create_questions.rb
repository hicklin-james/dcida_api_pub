class CreateQuestions < ActiveRecord::Migration[4.2]
  def change
    create_table :questions do |t|

      t.string :question_text
      t.integer :question_type, null: false
      t.integer :question_response_type, null: false
      t.integer :question_order, null: false
      t.belongs_to :decision_aid, null: false

      t.userstamps
      t.timestamps null: false
    end
  end
end
