class AddResponseValueCalculationToQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :response_value_calculation, :string
  end
end
