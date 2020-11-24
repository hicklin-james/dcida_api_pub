class RemoveOldIconArrayGraphics < ActiveRecord::Migration[4.2]
  def change
    drop_table :icon_array_chart_graphics
  end
end
