class AddPlatformToDecisionAidUser < ActiveRecord::Migration[4.2]
  def change
  	add_column :decision_aid_users, :platform, :string
  end
end
