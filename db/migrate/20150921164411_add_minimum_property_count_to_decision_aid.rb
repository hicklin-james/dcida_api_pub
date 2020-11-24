class AddMinimumPropertyCountToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :minimum_property_count, :integer, default: 0
  end
end
