class AddDecisionAidTypeToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :decision_aid_type, :integer, null: false, default: 0
  end
end
