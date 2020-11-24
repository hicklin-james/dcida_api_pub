class ChangeDecisionAidUserPropertyTraditionalValueToFloat < ActiveRecord::Migration[4.2]
  def change
    change_column :decision_aid_user_properties, :traditional_value, :float
  end
end
