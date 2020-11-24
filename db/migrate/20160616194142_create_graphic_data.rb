class CreateGraphicData < ActiveRecord::Migration[4.2]
  def change
    create_table :graphic_data do |t|
      t.belongs_to :graphic
      t.string :value
      t.string :label
      t.string :color
      t.integer :graphic_data_order
      t.integer :sub_value # only used in horizontal bar chart
      t.integer :value_type
    end
  end
end
