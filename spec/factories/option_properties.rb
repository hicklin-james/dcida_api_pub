# == Schema Information
#
# Table name: option_properties
#
#  id                    :integer          not null, primary key
#  information           :text
#  short_label           :text
#  option_id             :integer          not null
#  property_id           :integer          not null
#  decision_aid_id       :integer          not null
#  created_by_user_id    :integer
#  updated_by_user_id    :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  information_published :text
#  ranking               :text
#  ranking_type          :integer
#  short_label_published :text
#  button_label          :string
#

FactoryGirl.define do
  factory :option_property do
    sequence :information do |n|
      "option property #{n}"
    end
    sequence :short_label do |n|
      "option property short label #{n}"
    end
  end
end
