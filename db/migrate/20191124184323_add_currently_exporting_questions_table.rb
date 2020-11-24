class AddCurrentlyExportingQuestionsTable < ActiveRecord::Migration[4.2]
  def change
    create_table :currently_exporting_rdts do |t|
      t.integer :data_export_field_id
      t.integer :decision_aid_user_id 
      t.string :thread_id, null: false

      t.index [:data_export_field_id, :decision_aid_user_id], unique: true, name: "rdt_decision_aid_user_index"
    end
  end
end
