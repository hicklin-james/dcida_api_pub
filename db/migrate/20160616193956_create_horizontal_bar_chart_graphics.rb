class CreateHorizontalBarChartGraphics < ActiveRecord::Migration[4.2]
  def change
    create_table :horizontal_bar_chart_graphics do |t|
      t.string :selected_index
      t.integer :selected_index_type
    end
  end
end
