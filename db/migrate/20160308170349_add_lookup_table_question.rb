class AddLookupTableQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :lookup_table, :json
    add_column :questions, :lookup_table_x, :integer
    add_column :questions, :lookup_table_y, :integer
  end
end
