class AddMaximumPropertyCountToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :maximum_property_count, :integer, default: 0
  end
end
