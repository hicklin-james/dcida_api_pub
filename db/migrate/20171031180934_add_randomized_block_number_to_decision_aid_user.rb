class AddRandomizedBlockNumberToDecisionAidUser < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aid_users, :randomized_block_number, :integer
  end
end
