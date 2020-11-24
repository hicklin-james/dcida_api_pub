class AddDataExportFieldsCountToDecisionAids < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :data_export_fields_count, :integer, :null => false, :default => 0
  end
end
