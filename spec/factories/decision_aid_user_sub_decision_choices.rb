# == Schema Information
#
# Table name: decision_aid_user_sub_decision_choices
#
#  id                   :integer          not null, primary key
#  decision_aid_user_id :integer
#  sub_decision_id      :integer
#  option_id            :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

FactoryGirl.define do
  factory :decision_aid_user_sub_decision_choice do
    
  end
end
