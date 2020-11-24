# == Schema Information
#
# Table name: options
#
#  id                      :integer          not null, primary key
#  title                   :string           not null
#  label                   :string
#  description             :text
#  summary_text            :text
#  decision_aid_id         :integer          not null
#  created_by_user_id      :integer
#  updated_by_user_id      :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  media_file_id           :integer
#  question_response_array :integer          default([]), is an Array
#  description_published   :text
#  summary_text_published  :text
#  option_order            :integer
#  option_id               :integer
#  has_sub_options         :boolean          not null
#  sub_decision_id         :integer
#  generic_name            :string
#

class OptionSerializer < ActiveModel::Serializer

  attributes :id,
    :title,
    :description,
    :updated_at,
    :created_at,
    :created_by_user_id,
    :label,
    :summary_text,
    :decision_aid_id,
    :media_file_id,
    :decision_aid_id,
    :question_response_array,
    :option_order,
    :has_sub_options,
    :sub_option_ids,
    :sub_decision_id,
    :generic_name

end
