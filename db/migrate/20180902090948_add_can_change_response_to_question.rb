class AddCanChangeResponseToQuestion < ActiveRecord::Migration[4.2]
  def change
  	add_column :questions, :can_change_response, :boolean, default: true
  end
end
