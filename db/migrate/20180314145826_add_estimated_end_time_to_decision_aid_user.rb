class AddEstimatedEndTimeToDecisionAidUser < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aid_users, :estimated_end_time, :datetime
  end
end
