class AddBackendIdentifiersToRelevantModels < ActiveRecord::Migration[4.2]
  def change
  	add_column :questions, :backend_identifier, :string
  	add_column :properties, :backend_identifier, :string
  	add_column :summary_pages, :backend_identifier, :string
  end
end
