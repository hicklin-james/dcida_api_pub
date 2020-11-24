class CreateDecisionAidUserSessions < ActiveRecord::Migration[4.2]
  def change
    create_table :decision_aid_user_sessions do |t|

      t.integer :decision_aid_user_id, null: false
      t.timestamp :last_access, null: false

      t.timestamps null: false
    end
  end
end
