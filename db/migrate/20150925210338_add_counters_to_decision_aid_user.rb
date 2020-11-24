class AddCountersToDecisionAidUser < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aid_users, :decision_aid_user_responses_count, :integer, :null => false, :default => 0
    add_column :decision_aid_users, :decision_aid_user_properties_count, :integer, :null => false, :default => 0
    add_column :decision_aid_users, :decision_aid_user_option_properties_count, :integer, :null => false, :default => 0
  end
end
