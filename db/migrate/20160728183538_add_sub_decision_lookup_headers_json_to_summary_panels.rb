class AddSubDecisionLookupHeadersJsonToSummaryPanels < ActiveRecord::Migration[4.2]
  def change
    add_column :summary_panels, :lookup_headers_json, :json
  end
end
