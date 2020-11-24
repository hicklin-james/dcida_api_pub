class CreateAnimatedIconArrayGraphicStage < ActiveRecord::Migration[4.2]
  def change
    create_table :animated_icon_array_graphic_stages do |t|
      t.belongs_to :animated_icon_array_graphic
    	t.integer :total_n
      t.string :general_label
      t.boolean :seperate_values, default: false
      t.integer :graphic_stage_order, null: false
    end

    add_reference :graphic_data, :animated_icon_array_graphic_stage, index: true
  end
end
