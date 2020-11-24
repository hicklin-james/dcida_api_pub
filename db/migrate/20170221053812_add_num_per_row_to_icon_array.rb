class AddNumPerRowToIconArray < ActiveRecord::Migration[4.2]
  def change
    add_column :icon_array_graphics, :num_per_row, :integer
  end
end
