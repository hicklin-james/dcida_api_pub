class CreateSummaryPanels < ActiveRecord::Migration[4.2]
  def change
    create_table :summary_panels do |t|

      t.integer :panel_type
      t.text :panel_information
      t.text :panel_information_published
      t.integer :question_ids, array: true
      t.integer :summary_panel_order
      t.integer :decision_aid_id

      t.userstamps
      t.timestamps null: false
    end
  end
end
