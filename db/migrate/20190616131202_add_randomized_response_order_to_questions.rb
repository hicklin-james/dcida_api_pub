class AddRandomizedResponseOrderToQuestions < ActiveRecord::Migration[4.2]
  def change
  	add_column :questions, :randomized_response_order, :boolean, default: false
  end
end
