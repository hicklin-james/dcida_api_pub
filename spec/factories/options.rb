# == Schema Information
#
# Table name: options
#
#  id                      :integer          not null, primary key
#  title                   :string           not null
#  label                   :string
#  description             :text
#  summary_text            :text
#  decision_aid_id         :integer          not null
#  created_by_user_id      :integer
#  updated_by_user_id      :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  media_file_id           :integer
#  question_response_array :integer          default([]), is an Array
#  description_published   :text
#  summary_text_published  :text
#  option_order            :integer
#  option_id               :integer
#  has_sub_options         :boolean          not null
#  sub_decision_id         :integer
#  generic_name            :string
#

FactoryGirl.define do
  factory :option do
    has_sub_options false
    question_response_array []
    
    sequence :title do |n|
      "option title #{n}"
    end
    sequence :label do |n|
      "option label #{n}"
    end
    sequence :description do |n|
      "description #{n}"
    end
    sequence :summary_text do |n|
      "summary text #{n}"
    end

    after(:build) do |option, evaluator|
      if option.decision_aid_id
        option.initialize_order(option.decision_aid.reload.options_count)
      end
    end

    factory :option_with_sub_options do
      has_sub_options true

      transient do
        sub_options_count 4
      end

      before(:create) do |option, evaluator|
        sub_option_attrs = []
        0.upto(evaluator.sub_options_count-1) do |i|
          sub_option_attrs.push(FactoryGirl.attributes_for(:option, 
                                                            title: evaluator.title, 
                                                            label: "#{evaluator.label}_i", 
                                                            description: evaluator.description, 
                                                            summary_text: evaluator.summary_text,
                                                            decision_aid: evaluator.decision_aid,
                                                            question_response_array: evaluator.question_response_array,
                                                            sub_decision_id: evaluator.decision_aid.sub_decisions.first.id
                                                            ))
        end
        option.sub_options_attributes = sub_option_attrs
      end
    end
  end
end
