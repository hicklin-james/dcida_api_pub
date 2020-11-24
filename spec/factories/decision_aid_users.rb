# == Schema Information
#
# Table name: decision_aid_users
#
#  id                                                 :integer          not null, primary key
#  decision_aid_id                                    :integer          not null
#  selected_option_id                                 :integer
#  created_at                                         :datetime         not null
#  updated_at                                         :datetime         not null
#  decision_aid_user_responses_count                  :integer          default(0), not null
#  decision_aid_user_properties_count                 :integer          default(0), not null
#  decision_aid_user_option_properties_count          :integer          default(0), not null
#  decision_aid_user_dce_question_set_responses_count :integer          default(0), not null
#  decision_aid_user_bw_question_set_responses_count  :integer          default(0), not null
#  decision_aid_user_sub_decision_choices_count       :integer          default(0), not null
#  about_me_complete                                  :boolean          default(FALSE)
#  quiz_complete                                      :boolean          default(FALSE)
#  randomized_block_number                            :integer
#  unique_id_name                                     :integer
#  estimated_end_time                                 :datetime
#  other_properties                                   :text
#  platform                                           :string
#

FactoryGirl.define do
  factory :decision_aid_user do

    factory :decision_aid_user_with_responses do
      transient do
        question_ids_hash {}
        other_question_ids []
      end

      after(:create) do |decision_aid_user, evaluator|
        evaluator.question_ids_hash.each do |k,v|
          create(:decision_aid_user_response, question_id: k, question_response_id: v, decision_aid_user: decision_aid_user)
        end
        evaluator.other_question_ids.each do |qid|
          create(:decision_aid_user_response, question_id: qid, decision_aid_user: decision_aid_user)
        end
      end

      factory :decision_aid_user_with_properties do
        transient do
          property_hash {}
        end

        after(:create) do |decision_aid_user, evaluator|
          evaluator.property_hash.each do |k,v|
            create(:decision_aid_user_property, property_id: k, weight: v, decision_aid_user: decision_aid_user)
          end
        end
      end
    end
  end
end
