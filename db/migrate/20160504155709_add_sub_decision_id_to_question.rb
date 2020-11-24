class AddSubDecisionIdToQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :sub_decision_id, :integer
  end
end
