class AddRedcapFieldsToQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :remote_data_source, :boolean, default: false
    add_column :questions, :remote_data_source_type, :integer
    add_column :questions, :redcap_field_name, :string
  end
end
