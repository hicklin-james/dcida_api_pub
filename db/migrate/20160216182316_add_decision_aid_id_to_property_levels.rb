class AddDecisionAidIdToPropertyLevels < ActiveRecord::Migration[4.2]
  def change
    add_column :property_levels, :decision_aid_id, :integer
  end
end
