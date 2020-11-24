class AddMySqlParametersToQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :my_sql_procedure_name, :string
  end
end
