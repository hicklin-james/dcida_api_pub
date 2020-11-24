class AddDecisionAidIdToAccordions < ActiveRecord::Migration[4.2]
  def up
  	add_reference :accordions, :decision_aid, index: true
  	add_foreign_key :accordions, :decision_aids

  	add_reference :accordion_contents, :decision_aid, index: true
  	add_foreign_key :accordion_contents, :decision_aids
  end

  def down
  	remove_foreign_key :accordions, :decision_aid
  	remove_reference :accordions, :decision_aids

  	remove_reference :accordion_contents, :decision_aid, index: true
  	remove_foreign_key :accordion_contents, :decision_aids
  end
end
