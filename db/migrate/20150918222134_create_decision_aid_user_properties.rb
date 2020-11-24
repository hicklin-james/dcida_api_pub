class CreateDecisionAidUserProperties < ActiveRecord::Migration[4.2]
  def change
    create_table :decision_aid_user_properties do |t|

      t.integer :property_id
      t.integer :decision_aid_user_id
      t.integer :weight, default: 50
      t.integer :order, null: false
      t.string :color, null: false
      

      t.timestamps null: false
    end
  end
end
