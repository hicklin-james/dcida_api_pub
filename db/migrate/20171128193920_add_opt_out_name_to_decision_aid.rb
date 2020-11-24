class AddOptOutNameToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :opt_out_label, :string, default: "Opt Out"
  end
end
