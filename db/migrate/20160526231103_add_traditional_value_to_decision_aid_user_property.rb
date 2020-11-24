class AddTraditionalValueToDecisionAidUserProperty < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aid_user_properties, :traditional_value, :integer
  end
end
