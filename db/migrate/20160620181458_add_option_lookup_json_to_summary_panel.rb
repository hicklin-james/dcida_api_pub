class AddOptionLookupJsonToSummaryPanel < ActiveRecord::Migration[4.2]
  def change
    add_column :summary_panels, :option_lookup_json, :json
  end
end
