# == Schema Information
#
# Table name: question_responses
#
#  id                          :integer          not null, primary key
#  question_id                 :integer          not null
#  decision_aid_id             :integer          not null
#  question_response_value     :string
#  is_correct_value            :boolean
#  question_response_order     :integer          not null
#  created_by_user_id          :integer
#  updated_by_user_id          :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  numeric_value               :float
#  redcap_response_value       :string
#  popup_information           :text
#  popup_information_published :text
#  include_popup_information   :boolean          default(FALSE)
#  skip_logic_target_count     :integer          default(0), not null
#

FactoryGirl.define do
  factory :question_response do
    sequence :question_response_value do |n|
      "question response #{n}"
    end
  end
end
