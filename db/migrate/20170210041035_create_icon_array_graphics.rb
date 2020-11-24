class CreateIconArrayGraphics < ActiveRecord::Migration[4.2]
  def change
    create_table :icon_array_graphics do |t|
      t.string :selected_index
      t.integer :selected_index_type
      t.integer :max_value
    end
  end
end
