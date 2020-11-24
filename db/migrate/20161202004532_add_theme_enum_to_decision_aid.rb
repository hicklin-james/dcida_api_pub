class AddThemeEnumToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :theme, :integer, null: false, default: 0
  end
end
