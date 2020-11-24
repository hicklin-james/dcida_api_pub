class AddDceColorsToDecisionAids < ActiveRecord::Migration[4.2]
  def change
  	add_column :decision_aids, :dce_min_level_color, :string
  	add_column :decision_aids, :dce_max_level_color, :string
  end
end
