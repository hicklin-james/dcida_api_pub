# == Schema Information
#
# Table name: property_levels
#
#  id                    :integer          not null, primary key
#  information           :text
#  information_published :text
#  level_id              :integer
#  property_id           :integer          not null
#  created_by_user_id    :integer
#  updated_by_user_id    :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  decision_aid_id       :integer
#

FactoryGirl.define do
  factory :property_level do
    sequence :information do |n|
      "information #{n}"
    end
  end

end
