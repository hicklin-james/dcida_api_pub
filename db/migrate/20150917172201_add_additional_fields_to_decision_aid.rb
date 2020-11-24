class AddAdditionalFieldsToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :about_information, :text
    add_column :decision_aids, :options_information, :text
    add_column :decision_aids, :properties_information, :text
    add_column :decision_aids, :property_weight_information, :text
    add_column :decision_aids, :results_information, :text
    add_column :decision_aids, :quiz_information, :text
  end
end
