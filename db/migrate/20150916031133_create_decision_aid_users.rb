class CreateDecisionAidUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :decision_aid_users do |t|

      t.integer :decision_aid_id, null: false
      t.integer :selected_option_id
      t.string :uuid, null: false
      t.integer :pid

      t.timestamps null: false
    end
  end
end
