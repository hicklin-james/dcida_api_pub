class AddDceSelectionLabelToDecisionAids < ActiveRecord::Migration[4.2]
  def change
  	add_column :decision_aids, :dce_selection_label, :string, default: "Which do you prefer?"
  end
end
