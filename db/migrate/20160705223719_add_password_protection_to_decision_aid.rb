class AddPasswordProtectionToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :password_protected, :boolean
    add_column :decision_aids, :access_password, :string
  end
end