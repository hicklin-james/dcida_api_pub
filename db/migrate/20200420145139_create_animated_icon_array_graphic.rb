class CreateAnimatedIconArrayGraphic < ActiveRecord::Migration[4.2]
  def change
    create_table :animated_icon_array_graphics do |t|
    	t.boolean :indicators_above, default: false
      t.integer :default_stage, default: 0
    end
  end
end