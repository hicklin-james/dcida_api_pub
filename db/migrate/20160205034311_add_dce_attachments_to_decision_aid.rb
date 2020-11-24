class AddDceAttachmentsToDecisionAid < ActiveRecord::Migration[4.2]
  def up
    add_attachment :decision_aids, :dce_design_file
    add_attachment :decision_aids, :dce_results_file
  end

  def down
    remove_attachment :decision_aids, :dce_design_file
    remove_attachment :decision_aids, :dce_results_file
  end
end
