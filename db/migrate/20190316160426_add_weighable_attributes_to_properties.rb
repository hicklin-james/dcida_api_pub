class AddWeighableAttributesToProperties < ActiveRecord::Migration[4.2]
  def change
    add_column :properties, :is_property_weighable, :boolean, default: true
    add_column :properties, :are_option_properties_weighable, :boolean, default: true
  end
end
