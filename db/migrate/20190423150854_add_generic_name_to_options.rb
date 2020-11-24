class AddGenericNameToOptions < ActiveRecord::Migration[4.2]
  def change
  	add_column :options, :generic_name, :string
  end
end
