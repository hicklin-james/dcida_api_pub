class CreateDataExportFields < ActiveRecord::Migration[4.2]
  def up
    create_table :data_export_fields do |t|
      t.references :exporter, polymorphic: true, null: false
      t.belongs_to :decision_aid, null: false
      t.integer :data_target_type, null: false
      t.integer :data_export_field_order, null: false

      t.string :redcap_field_name
      t.json :redcap_response_mapping

      t.userstamps
      t.timestamps null: false
    end

    DecisionAid.all.each do |da|

      Question.where(remote_data_target: true, decision_aid_id: da.id).where.not(redcap_field_name: nil).all.ordered.each_with_index do |q, ind|
        de = DataExportField.new()
        de.data_export_field_order = ind + 1
        de.decision_aid_id = q.decision_aid_id
        de.exporter_type = "Question"
        de.exporter_id = q.id
        de.data_target_type = "redcap"
        de.redcap_field_name = q.redcap_field_name
        if q.question_response_type == 'radio' or q.question_response_type == "yes_no"
          mapping = {}
          q.question_responses.each do |qr|
            mapping[qr.id.to_s] = qr.redcap_response_value
          end
          de.redcap_response_mapping = mapping
        end
        de.save!
      end
    end
  end

  def down
    DataExportField.where(exporter_type: "Question").all.each do |f|
      q = Question.find_by(id: f.exporter_id)
      if q
        q.remote_data_target = true
        q.remote_data_target_type = 'redcap_t'
        q.redcap_field_name = f.redcap_field_name
        if q.question_response_type == 'radio' or q.question_response_type == "yes_no"
          q.question_responses.each do |qr|
            qr.redcap_response_value = f.redcap_response_mapping[qr.id.to_s]
            qr.save!
          end
        end
        q.save!
      end
    end

    drop_table :data_export_fields
  end
end
