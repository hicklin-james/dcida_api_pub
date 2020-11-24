class AddSubDecisionCounterToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :sub_decisions_count, :integer, :null => false, :default => 0
  end
end
