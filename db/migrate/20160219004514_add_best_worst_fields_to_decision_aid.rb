class AddBestWorstFieldsToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :best_worst_information, :text
    add_column :decision_aids, :best_worst_information_published, :text
    add_column :decision_aids, :best_worst_specific_information, :text
    add_column :decision_aids, :best_worst_specific_information_published, :text
  end
end
