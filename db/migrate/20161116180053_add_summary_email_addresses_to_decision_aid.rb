class AddSummaryEmailAddressesToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :summary_email_addresses, :string, array: true, default: []
  end
end
