class AddUniqueIdNameToDecisionAidUsers < ActiveRecord::Migration[4.2]
  def up
    add_column :decision_aid_users, :unique_id_name, :integer
    change_column :decision_aid_users, :pid, :string

    DecisionAidUser.update_all(unique_id_name: 0)
  end

  def down
    change_column :decision_aid_users, :pid, 'integer USING CAST(pid AS integer)'
    remove_column :decision_aid_users, :unique_id_name
  end
end
