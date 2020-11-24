# == Schema Information
#
# Table name: data_export_fields
#
#  id                      :integer          not null, primary key
#  exporter_id             :integer          not null
#  exporter_type           :string           not null
#  decision_aid_id         :integer          not null
#  data_target_type        :integer          not null
#  data_export_field_order :integer          not null
#  redcap_field_name       :string
#  redcap_response_mapping :json
#  created_by_user_id      :integer
#  updated_by_user_id      :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  data_accessor           :string
#

class DataExportFieldSerializer < ActiveModel::Serializer

  attributes :id, 
    :exporter_id, 
    :exporter_type, 
    :data_target_type, 
    :redcap_field_name, 
    :redcap_response_mapping,
    :exporter,
    :data_export_field_order,
    :data_accessor

  def exporter
    case object.exporter_type
    when "Question"
      q = QuestionSerializer.new(object.exporter, skip_skip_logic_targets: true)
      adapter = ActiveModelSerializers::Adapter::Attributes.new(q)
      adapter.as_json
    when "Property"
      nil
    else
      nil
    end
  end

end
