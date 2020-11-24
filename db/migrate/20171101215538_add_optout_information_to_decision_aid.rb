class AddOptoutInformationToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :opt_out_information, :text
    add_column :decision_aids, :opt_out_information_published, :text
  end
end
