class AddMinMaxValuesToNumberQuestions < ActiveRecord::Migration[4.2]
  def change
  	add_column :questions, :min_number, :integer
  	add_column :questions, :max_number, :integer
  	add_column :questions, :min_chars, :integer
  	add_column :questions, :max_chars, :integer
  end
end
