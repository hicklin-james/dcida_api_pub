class RemoveLookupTableXAndYFromQuestions < ActiveRecord::Migration[4.2]
  def change
    remove_column :questions, :lookup_table_x
    remove_column :questions, :lookup_table_y
  end
end
