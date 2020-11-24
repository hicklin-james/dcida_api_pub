class AddRedcapUniqueIdentifierToDecisionAid < ActiveRecord::Migration[4.2]
  def change
  	add_column :decision_aids, :unique_redcap_record_identifier, :string
  end
end
