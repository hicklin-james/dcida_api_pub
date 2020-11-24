class AddBestWorstPageLabelToDecisionAids < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :best_worst_page_label, :string, default: "My Values"
  end
end
