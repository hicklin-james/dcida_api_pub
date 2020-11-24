class AddAutoSubmitForDce < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :properties_auto_submit, :boolean, default: true
  end
end
