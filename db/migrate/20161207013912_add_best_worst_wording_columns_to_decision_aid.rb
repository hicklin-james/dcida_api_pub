class AddBestWorstWordingColumnsToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :best_wording, :string, default: "Best"
    add_column :decision_aids, :worst_wording, :string, default: "Worst"
  end
end
