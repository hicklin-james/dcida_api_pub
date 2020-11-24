class AddAdditionalAttributesToAccordions < ActiveRecord::Migration[4.2]
  def change
    add_column :accordion_contents, :is_open_by_default, :boolean
    add_column :accordion_contents, :panel_color, :integer
  end
end
