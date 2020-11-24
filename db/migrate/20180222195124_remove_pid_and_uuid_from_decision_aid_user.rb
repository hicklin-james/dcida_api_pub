class RemovePidAndUuidFromDecisionAidUser < ActiveRecord::Migration[4.2]
  def change
    remove_column :decision_aid_users, :pid
    remove_column :decision_aid_users, :uuid
  end
end
