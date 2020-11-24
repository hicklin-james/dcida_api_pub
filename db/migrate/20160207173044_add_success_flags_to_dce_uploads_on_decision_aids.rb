class AddSuccessFlagsToDceUploadsOnDecisionAids < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :dce_design_success, :boolean, default: false
    add_column :decision_aids, :dce_results_success, :boolean, default: false
  end
end
