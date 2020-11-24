class AddButtonLabelToOptionProperties < ActiveRecord::Migration[4.2]
  def change
  	add_column :option_properties, :button_label, :string
  end
end
