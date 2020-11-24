class AddResultTypeBooleansToDecisionAids < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :ratings_enabled, :boolean
    add_column :decision_aids, :percentages_enabled, :boolean
    add_column :decision_aids, :best_match_enabled, :boolean
  end
end
