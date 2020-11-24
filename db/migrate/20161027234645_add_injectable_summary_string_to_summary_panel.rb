class AddInjectableSummaryStringToSummaryPanel < ActiveRecord::Migration[4.2]
  def change
    add_column :summary_panels, :injectable_decision_summary_string, :string
  end
end
