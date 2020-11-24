class AddOptOutInformationFieldToProperties < ActiveRecord::Migration[4.2]
  def change
    add_column :properties, :opt_out_information, :text
    add_column :properties, :opt_out_information_published, :text
  end
end
