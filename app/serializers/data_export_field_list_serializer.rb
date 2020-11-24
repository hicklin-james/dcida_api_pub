class DataExportFieldListSerializer < ActiveModel::Serializer

  attributes :id, 
    :exporter_id, 
    :exporter_type, 
    :data_target_type, 
    :redcap_field_name, 
    :redcap_response_mapping,
    :backend_identifier,
    :decision_aid_id

end