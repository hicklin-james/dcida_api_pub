class AddAdditionalAttributesToDecisionAids < ActiveRecord::Migration[4.2]
  def change
  	add_column :decision_aids, :hide_menu_bar, :boolean, default: false
  	add_column :decision_aids, :open_summary_link_in_new_tab, :boolean, default: true 
  end
end
