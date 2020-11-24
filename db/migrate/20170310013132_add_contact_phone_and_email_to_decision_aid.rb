class AddContactPhoneAndEmailToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :contact_phone_number, :string
    add_column :decision_aids, :contact_email, :string
  end
end
