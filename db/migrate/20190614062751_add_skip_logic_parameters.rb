class AddSkipLogicParameters < ActiveRecord::Migration[4.2]
  def change
    create_table :skip_logic_targets do |t|
      t.belongs_to :question
      t.belongs_to :question_response
      t.belongs_to :decision_aid

      t.integer :target_entity
      t.integer :skip_question_id
      t.string :skip_page_url

      t.integer :skip_logic_target_order, null: false

      t.userstamps
      t.timestamps null: false
    end

    create_table :skip_logic_conditions do |t|
      t.belongs_to :skip_logic_target
      t.belongs_to :decision_aid

      t.integer :condition_entity
      t.string :entity_lookup
      t.string :entity_value_key
      
      t.string :value_to_match
      
      t.integer :logical_operator

      t.integer :skip_logic_condition_order, null: false

      t.userstamps
      t.timestamps null: false
    end

    add_column :questions, :skip_logic_target_count, :integer, :null => false, :default => 0
    add_column :question_responses, :skip_logic_target_count, :integer, :null => false, :default => 0
  end
end
