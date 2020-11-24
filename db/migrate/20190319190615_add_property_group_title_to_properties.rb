class AddPropertyGroupTitleToProperties < ActiveRecord::Migration[4.2]
  def change
  	add_column :properties, :property_group_title, :string
  end
end
