class AddIconArrayChart < ActiveRecord::Migration[4.2]
  def change
    create_table :icon_array_chart_graphics do |t|
      t.integer :num_icons_per_row
      t.string :max_value
    end
  end
end
