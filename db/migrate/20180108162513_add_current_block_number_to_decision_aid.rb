class AddCurrentBlockNumberToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :current_block_number, :integer, default: 1, null: false
  end
end
