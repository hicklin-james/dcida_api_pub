class AddPropertyLevelCountToProperty < ActiveRecord::Migration[4.2]
  def change
    add_column :properties, :property_levels_count, :integer, :null => false, :default => 0
  end
end
