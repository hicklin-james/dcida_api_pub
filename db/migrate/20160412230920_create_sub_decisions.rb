class CreateSubDecisions < ActiveRecord::Migration[4.2]
  def change
    create_table :sub_decisions do |t|
      t.belongs_to :decision_aid
      t.integer :sub_decision_order
      t.integer :required_option_ids, array: true

      t.userstamps
      t.timestamps null: false
    end
  end
end
