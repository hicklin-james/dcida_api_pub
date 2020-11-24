class DecisionAidHomeSummaryPanelSerializer < ActiveModel::Serializer

  attributes :id,
    :summary_panel_order,
    :decision_aid_id,
    :question_ids,
    :panel_type,
    :option_lookup_json,
    :injected_panel_information_published,
    :lookup_headers_json,
    :summary_table_header_json
    :injectable_decision_summary_string

  def injected_panel_information_published
    object.injected_panel_information_published(instance_options[:decision_aid_user])
  end

  def injectable_decision_summary_string
    object.injected_injectable_decision_summary_string(instance_options[:decision_aid_user])
  end

end