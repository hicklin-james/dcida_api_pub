class AddOptionFallbackToDecisionAids < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :fallback_on_option, :boolean, default: false
    add_column :decision_aids, :fallback_option, :integer
  end
end
