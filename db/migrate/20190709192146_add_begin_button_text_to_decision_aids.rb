class AddBeginButtonTextToDecisionAids < ActiveRecord::Migration[4.2]
  def change
  	add_column :decision_aids, :begin_button_text, :string, default: "Begin", null: false
  end
end
