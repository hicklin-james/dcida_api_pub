class AddMaxValueToHorizontalBarChart < ActiveRecord::Migration[4.2]
  def change
    add_column :horizontal_bar_chart_graphics, :max_value, :string
  end
end
