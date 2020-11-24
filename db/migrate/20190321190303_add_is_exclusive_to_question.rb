class AddIsExclusiveToQuestion < ActiveRecord::Migration[4.2]
  def change
  	add_column :questions, :is_exclusive, :boolean, default: false
  end
end
