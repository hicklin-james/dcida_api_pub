class AddCustomCssToDecisionAid < ActiveRecord::Migration[4.2]
  def change
  	add_column :decision_aids, :custom_css, :text
  end
end
