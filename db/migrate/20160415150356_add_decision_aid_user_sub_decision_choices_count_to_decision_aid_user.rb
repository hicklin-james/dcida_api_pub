class AddDecisionAidUserSubDecisionChoicesCountToDecisionAidUser < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aid_users, :decision_aid_user_sub_decision_choices_count, :integer, :null => false, :default => 0
  end
end
