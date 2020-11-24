# == Schema Information
#
# Table name: summary_panels
#
#  id                                 :integer          not null, primary key
#  panel_type                         :integer
#  panel_information                  :text
#  panel_information_published        :text
#  question_ids                       :integer          default([]), is an Array
#  summary_panel_order                :integer
#  decision_aid_id                    :integer
#  created_by_user_id                 :integer
#  updated_by_user_id                 :integer
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  option_lookup_json                 :json
#  lookup_headers_json                :json
#  summary_table_header_json          :json
#  injectable_decision_summary_string :string
#  summary_page_id                    :integer          not null
#

class SummaryPanelSerializer < ActiveModel::Serializer
  attributes :id,
    :summary_panel_order,
    :panel_information,
    :panel_type,
    :question_ids,
    :decision_aid_id,
    :option_lookup_json,
    :lookup_headers_json,
    :summary_table_header_json,
    :injectable_decision_summary_string,
    :summary_page_id
end
