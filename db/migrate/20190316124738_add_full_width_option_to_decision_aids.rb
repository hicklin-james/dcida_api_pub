class AddFullWidthOptionToDecisionAids < ActiveRecord::Migration[4.2]
  def change
  	add_column :decision_aids, :full_width, :boolean, default: false
  end
end
