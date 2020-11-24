# == Schema Information
#
# Table name: properties
#
#  id                              :integer          not null, primary key
#  title                           :string
#  selection_about                 :text
#  long_about                      :text
#  decision_aid_id                 :integer          not null
#  created_by_user_id              :integer
#  updated_by_user_id              :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  selection_about_published       :text
#  long_about_published            :text
#  property_order                  :integer
#  property_levels_count           :integer          default(0), not null
#  short_label                     :string
#  is_property_weighable           :boolean          default(TRUE)
#  are_option_properties_weighable :boolean          default(TRUE)
#  property_group_title            :string
#  backend_identifier              :string
#

FactoryGirl.define do
  factory :property do
    property_order 1
    sequence :title do |n|
      "property title #{n}"
    end
    sequence :selection_about do |n|
      "selection about #{n}"
    end
    sequence :long_about do |n|
      "long about #{n}"
    end

    after(:build) do |prop, evaluator|
      if prop.decision_aid_id and DecisionAid.exists?(prop.decision_aid_id)
        prop.initialize_order(DecisionAid.find(prop.decision_aid_id).properties_count)
      end
    end

    factory :property_with_levels do
      transient do
        property_level_count 5
      end

      before(:create) do |property, evaluator|
        level_attrs = []
        0.upto(evaluator.property_level_count-1) do |i|
          level_attrs.push FactoryGirl.attributes_for(:property_level, level_id: i, decision_aid_id: property.decision_aid_id)
        end
        property.property_levels_attributes = level_attrs
      end
    end
  end
end
