# == Schema Information
#
# Table name: sub_decisions
#
#  id                                  :integer          not null, primary key
#  decision_aid_id                     :integer
#  sub_decision_order                  :integer
#  required_option_ids                 :integer          default([]), is an Array
#  created_by_user_id                  :integer
#  updated_by_user_id                  :integer
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  options_information                 :text
#  options_information_published       :text
#  other_options_information           :text
#  other_options_information_published :text
#  my_choice_information               :text
#  my_choice_information_published     :text
#  option_question_text                :text
#

FactoryGirl.define do
  factory :sub_decision do
    
  end
end
