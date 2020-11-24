# == Schema Information
#
# Table name: accordions
#
#  id               :integer          not null, primary key
#  title            :string           not null
#  decision_aid_ids :integer          default([]), is an Array
#  user_id          :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  decision_aid_id  :integer
#

FactoryGirl.define do
  factory :accordion do
    sequence :title do |n|
      "Accordion #{n}"
    end

    transient do
      contents_count 5
    end

    after(:create) do |accordion, evaluator|
      create_list(:accordion_content, evaluator.contents_count, accordion: accordion, decision_aid_id: accordion.decision_aid_id)
    end
  end
end
