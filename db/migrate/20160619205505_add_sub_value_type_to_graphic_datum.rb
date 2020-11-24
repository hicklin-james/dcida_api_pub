class AddSubValueTypeToGraphicDatum < ActiveRecord::Migration[4.2]
  def change
    add_column :graphic_data, :sub_value_type, :integer
    change_column :graphic_data, :sub_value, :string
  end
end
