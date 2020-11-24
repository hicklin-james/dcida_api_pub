class AddChartTypeToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :chart_type, :integer, default: 0
  end
end
