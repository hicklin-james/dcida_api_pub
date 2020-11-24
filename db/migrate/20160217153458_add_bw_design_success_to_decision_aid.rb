class AddBwDesignSuccessToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :bw_design_success, :boolean, default: false
  end
end
