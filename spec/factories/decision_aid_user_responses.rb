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

FactoryGirl.define do
  factory :decision_aid_user_response do
    factory :decision_aid_user_text_response do
      response_value "Text response!"
    end    
  end
end
