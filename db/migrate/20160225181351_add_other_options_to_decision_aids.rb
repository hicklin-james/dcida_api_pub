class AddOtherOptionsToDecisionAids < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :other_options_information, :text
    add_column :decision_aids, :other_options_information_published, :text
  end
end
