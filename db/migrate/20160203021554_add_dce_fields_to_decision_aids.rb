class AddDceFieldsToDecisionAids < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :dce_information, :text
    add_column :decision_aids, :dce_information_published, :text
    add_column :decision_aids, :dce_specific_information, :text
    add_column :decision_aids, :dce_specific_information_published, :text
  end
end
