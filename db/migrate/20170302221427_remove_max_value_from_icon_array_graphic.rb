class RemoveMaxValueFromIconArrayGraphic < ActiveRecord::Migration[4.2]
  def change
    remove_column :icon_array_graphics, :max_value
  end
end
