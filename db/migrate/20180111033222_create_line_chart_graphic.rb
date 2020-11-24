class CreateLineChartGraphic < ActiveRecord::Migration[4.2]
  def change
    create_table :line_chart_graphics do |t|
      t.string :x_label
      t.string :y_label
      t.string :chart_title
      t.integer :min_value
      t.integer :max_value
    end
  end
end
