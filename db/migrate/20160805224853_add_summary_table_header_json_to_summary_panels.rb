class AddSummaryTableHeaderJsonToSummaryPanels < ActiveRecord::Migration[4.2]
  def change
    add_column :summary_panels, :summary_table_header_json, :json
  end
end
