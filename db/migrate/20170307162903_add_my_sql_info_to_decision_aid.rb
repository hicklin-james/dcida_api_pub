class AddMySqlInfoToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :mysql_dbname, :string
    add_column :decision_aids, :mysql_user, :string
    add_column :decision_aids, :mysql_password, :string
  end
end
