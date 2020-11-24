class AddNewCountersToDecisionAid < ActiveRecord::Migration[4.2]
  def change
  	add_column :decision_aids, :static_pages_count, :integer, default: 0, null: false
  	add_column :decision_aids, :nav_links_count, :integer, default: 0, null: false
  end
end
