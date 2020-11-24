class AddIntroPagesCountToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :intro_pages_count, :integer, :null => false, :default => 0
  end
end
