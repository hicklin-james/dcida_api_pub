class AddDceTypeToDecisionAid < ActiveRecord::Migration[4.2]
  def change
  	add_column :decision_aids, :dce_type, :integer, default: 1
  end
end
