class AddTraditionalOptionIdToDecisionAidUserProperties < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aid_user_properties, :traditional_option_id, :integer
  end
end
