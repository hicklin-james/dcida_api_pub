class CreateDecisionAidUserOptionProperties < ActiveRecord::Migration[4.2]
  def change
    create_table :decision_aid_user_option_properties do |t|

      t.integer :option_property_id, null: false
      t.integer :option_id, null: false
      t.integer :property_id, null: false
      t.integer :decision_aid_user_id, null: false
      t.float :value, null: false

      t.timestamps null: false
    end
  end
end
