class AddExtraDceAttributesToDecisionAid < ActiveRecord::Migration[4.2]
  def change
  	add_column :decision_aids, :color_rows_based_on_attribute_levels, :boolean, default: false
  	add_column :decision_aids, :compare_opt_out_to_last_selected, :boolean, default: true
  end
end
