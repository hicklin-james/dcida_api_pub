class AddShortLabelToProperties < ActiveRecord::Migration[4.2]
  def change
    add_column :properties, :short_label, :string
  end
end
