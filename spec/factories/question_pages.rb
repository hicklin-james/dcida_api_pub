FactoryGirl.define do
  factory :question_page do
    after(:build) do |question_page, evaluator|
      question_page.initialize_order(DecisionAid.find(question_page.decision_aid_id).demographic_question_pages.count)
    end
  end
end
