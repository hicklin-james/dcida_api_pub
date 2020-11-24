class CreateQuestionPages < ActiveRecord::Migration[4.2]
  def change
    create_table :question_pages do |t|
      t.integer :section
      t.integer :question_page_order, null: false
      t.belongs_to :decision_aid, null: false

      t.userstamps
      t.timestamps null: false
    end
  end
end
