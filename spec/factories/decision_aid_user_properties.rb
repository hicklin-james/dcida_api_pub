# == Schema Information
#
# Table name: decision_aid_user_properties
#
#  id                    :integer          not null, primary key
#  property_id           :integer          not null
#  decision_aid_user_id  :integer          not null
#  weight                :integer          default(50)
#  order                 :integer          not null
#  color                 :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  traditional_value     :float
#  traditional_option_id :integer
#

FactoryGirl.define do
  factory :decision_aid_user_property do
    weight 50
    color 'white'
    sequence :order do |n|
      n
    end
  end 
end
