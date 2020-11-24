# == Schema Information
#
# Table name: decision_aid_user_responses
#
#  id                    :integer          not null, primary key
#  question_response_id  :integer
#  response_value        :text
#  question_id           :integer          not null
#  decision_aid_user_id  :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  number_response_value :float
#  lookup_table_value    :float
#  option_id             :integer
#  json_response_value   :json
#  selected_unit         :string
#

class DecisionAidUserResponseSerializer < ActiveModel::Serializer

  attributes :id,
    :question_response_id,
    :response_value,
    :question_id,
    :decision_aid_user_id,
    :number_response_value,
    :option_id,
    :url_to_skip_to,
    :json_response_value,
    :selected_unit,
    :skip_to

  def skip_to
    if instance_options[:skip_to]
      instance_options[:skip_to]
    else
      nil
    end
  end

  def url_to_skip_to
    if instance_options[:url_to_use]
      instance_options[:url_to_use]
    else
      ""
    end
  end

end
