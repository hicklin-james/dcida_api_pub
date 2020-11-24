class AddOtherPropertiesToDecisionAidUser < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aid_users, :other_properties, :text
  end
end
