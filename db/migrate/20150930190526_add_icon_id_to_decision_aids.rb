class AddIconIdToDecisionAids < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :icon_id, :integer
    add_column :decision_aids, :footer_logos, :integer, array: true, default: []
  end
end
