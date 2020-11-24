class AddSpecialFlagToQuestions < ActiveRecord::Migration[4.2]
  def change
  	add_column :questions, :special_flag, :integer, null: false, default: 1
  end
end
