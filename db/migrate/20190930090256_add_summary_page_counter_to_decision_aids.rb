class AddSummaryPageCounterToDecisionAids < ActiveRecord::Migration[4.2]
  def change
  	add_column :decision_aids, :summary_pages_count, :integer, :null => false, :default => 0
  end
end