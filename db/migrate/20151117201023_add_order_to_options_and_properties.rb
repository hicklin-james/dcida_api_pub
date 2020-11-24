class AddOrderToOptionsAndProperties < ActiveRecord::Migration[4.2]
  def change
    add_column :options, :option_order, :integer
    add_column :properties, :property_order, :integer
  end
end
