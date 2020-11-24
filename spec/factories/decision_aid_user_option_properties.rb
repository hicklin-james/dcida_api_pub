# == Schema Information
#
# Table name: decision_aid_user_option_properties
#
#  id                   :integer          not null, primary key
#  option_property_id   :integer          not null
#  option_id            :integer          not null
#  property_id          :integer          not null
#  decision_aid_user_id :integer          not null
#  value                :float            not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

FactoryGirl.define do
  factory :decision_aid_user_option_property do
    value 5
  end 
end
