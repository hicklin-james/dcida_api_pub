class AddSubDecisionIdToOptions < ActiveRecord::Migration[4.2]
  def change
    add_column :options, :sub_decision_id, :integer
  end
end
