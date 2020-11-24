class AddDecimalPointsToHiddenQuestionCalculation < ActiveRecord::Migration[4.2]
  def change
  	add_column :questions, :num_decimals_to_round_to, :integer, default: 0
  end
end
