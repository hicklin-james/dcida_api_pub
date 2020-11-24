class AddLanguageToDecisionAid < ActiveRecord::Migration[4.2]
  def change
  	add_column :decision_aids, :language_code, :integer, default: 0
  end
end
