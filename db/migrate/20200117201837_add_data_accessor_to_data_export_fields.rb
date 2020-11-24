class AddDataAccessorToDataExportFields < ActiveRecord::Migration[4.2]
  def change
    add_column :data_export_fields, :data_accessor, :string
  end
end
