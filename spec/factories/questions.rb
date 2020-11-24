# == Schema Information
#
# Table name: questions
#
#  id                           :integer          not null, primary key
#  question_text                :text
#  question_type                :integer          not null
#  question_response_type       :integer          not null
#  question_order               :integer          not null
#  decision_aid_id              :integer          not null
#  created_by_user_id           :integer
#  updated_by_user_id           :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  question_text_published      :text
#  question_id                  :integer
#  grid_questions_count         :integer          default(0), not null
#  hidden                       :boolean          default(FALSE)
#  response_value_calculation   :string
#  lookup_table                 :json
#  question_response_style      :integer
#  sub_decision_id              :integer
#  lookup_table_dimensions      :integer          default([]), is an Array
#  remote_data_source           :boolean          default(FALSE)
#  remote_data_source_type      :integer
#  redcap_field_name            :string
#  my_sql_procedure_name        :string
#  current_treatment_option_ids :integer          default([]), is an Array
#  slider_left_label            :string
#  slider_right_label           :string
#  slider_granularity           :integer
#  num_decimals_to_round_to     :integer          default(0)
#  can_change_response          :boolean          default(TRUE)
#  post_question_text           :text
#  post_question_text_published :text
#  slider_midpoint_label        :string
#  unit_of_measurement          :string
#  side_text                    :text
#  side_text_published          :text
#  skippable                    :boolean          default(FALSE)
#  special_flag                 :integer          default(1), not null
#  is_exclusive                 :boolean          default(FALSE)
#  randomized_response_order    :boolean          default(FALSE)
#  min_number                   :integer
#  max_number                   :integer
#  min_chars                    :integer
#  max_chars                    :integer
#  units_array                  :string           default([]), is an Array
#  remote_data_target           :boolean          default(FALSE)
#  remote_data_target_type      :integer
#  backend_identifier           :string
#  question_page_id             :integer
#

FactoryGirl.define do
  factory :question do
    hidden false
    num_decimals_to_round_to 0
    sequence :question_text do |n|
      "Question #{n}"
    end

    factory :grid_question do
      question_response_type 2
      question_response_style 3

      factory :demo_grid_question do
        question_type 0

        transient do
          grid_question_count 4
          grid_responses_count 4
        end

        after(:build) do |question, evalutor|
          if question.decision_aid
            question.initialize_order(question.order_scope.count)
          end
        end

        before(:create) do |question, evaluator|
          grid_question_attrs = []
          0.upto(evaluator.grid_question_count-1) do |i|
            response_attrs = []
            0.upto(evaluator.grid_responses_count-1) do |ii|
              response_attrs.push(FactoryGirl.attributes_for(:question_response, question_response_order: ii+1, decision_aid: evaluator.decision_aid))
            end
            grid_question_attrs.push(FactoryGirl.attributes_for(:demo_radio_question, question_order: i, decision_aid: evaluator.decision_aid, question_response_style: 0, question_responses_attributes: response_attrs))
          end
          question.grid_questions_attributes = grid_question_attrs

          if question.question_page_id.nil?
            qp = create(:question_page, decision_aid_id: question.decision_aid_id, section: "about")
            question.question_page_id = qp.id
          end
        end
      end
    end

    factory :radio_question do
      question_response_type 0
      question_response_style 0

      factory :demo_radio_question do
        question_type 0

        after(:build) do |question, evalutor|
          if question.decision_aid
            question.initialize_order(question.order_scope.count)
          end
        end

        before(:create) do |question, evaluator|
          if question.question.nil? and !question.hidden
            qp = create(:question_page, decision_aid_id: question.decision_aid_id, section: "about")
            question.question_page_id = qp.id
          end
        end
      end

      factory :quiz_radio_question do
        question_type 1

        after(:build) do |question, evalutor|
          if question.decision_aid
            question.initialize_order(question.order_scope.count)
          end
        end

        before(:create) do |question, evaluator|
          if question.question_page_id.nil? and !question.hidden
            qp = create(:question_page, decision_aid_id: question.decision_aid_id, section: "quiz")
            question.question_page_id = qp.id
          end
        end
      end

      transient do
        response_count 4
      end

      before(:create) do |question, evaluator|
        response_attrs = []
        0.upto(evaluator.response_count-1) do |i|
          response_attrs.push(FactoryGirl.attributes_for(:question_response, question_response_order: i, question: question, decision_aid: evaluator.decision_aid, numeric_value: i + 1))
        end
        question.question_responses_attributes = response_attrs
      end
    end

    factory :yes_no_question do
      question_response_type 5
      question_response_style 6

      factory :demo_yes_no_question do
        question_type 0

        after(:build) do |question, evalutor|
          if question.decision_aid
            question.initialize_order(question.order_scope.count)
          end
        end

        before(:create) do |question, evaluator|
          if question.question_page_id.nil? and !question.hidden
            qp = create(:question_page, decision_aid_id: question.decision_aid_id, section: "about")
            question.question_page_id = qp.id
          end
        end
      end

      factory :quiz_yes_no_question do
        question_type 1

        after(:build) do |question, evalutor|
          if question.decision_aid
            question.initialize_order(question.order_scope.count)
          end
        end

        before(:create) do |question, evaluator|
          if question.question_page_id.nil? and !question.hidden
            qp = create(:question_page, decision_aid_id: question.decision_aid_id, section: "quiz")
            question.question_page_id = qp.id
          end
        end
      end

      before(:create) do |question, evaluator|
        r1 = FactoryGirl.attributes_for(:question_response, question_response_order: 1, question: question, decision_aid: evaluator.decision_aid, numeric_value: 1)
        r2 = FactoryGirl.attributes_for(:question_response, question_response_order: 2, question: question, decision_aid: evaluator.decision_aid, numeric_value: 2)
        question.question_responses_attributes = [r1,r2]
      end
    end

    factory :text_question do
      question_response_type 1
      question_response_style 2

      factory :demo_text_question do
        question_type 0

        after(:build) do |question, evalutor|
          if question.decision_aid
            question.initialize_order(question.order_scope.count)
          end
        end

        before(:create) do |question, evaluator|
          if question.question_page_id.nil? and !question.hidden
            qp = create(:question_page, decision_aid_id: question.decision_aid_id, section: "about")
            question.question_page_id = qp.id
          end
        end
      end

      factory :quiz_text_question do
        question_type 1

        after(:build) do |question, evalutor|
          if question.decision_aid
            question.initialize_order(question.order_scope.count)
          end
        end

        before(:create) do |question, evaluator|
          if question.question_page_id.nil? and !question.hidden
            qp = create(:question_page, decision_aid_id: question.decision_aid_id, section: "quiz")
            question.question_page_id = qp.id
          end
        end
      end
    end

    factory :current_treatment_question do
      question_response_type 6
      question_response_style 7

      factory :demo_current_treatment_question do
        question_type 0

        after(:build) do |question, evalutor|
          if question.decision_aid
            question.initialize_order(question.order_scope.count)
          end
        end

        before(:create) do |question, evaluator|
          if question.question_page_id.nil? and !question.hidden
            qp = create(:question_page, decision_aid_id: question.decision_aid_id, section: "about")
            question.question_page_id = qp.id
          end
        end
      end

      factory :quiz_current_treatment_question do
        question_type 1

        after(:build) do |question, evalutor|
          if question.decision_aid
            question.initialize_order(question.order_scope.count)
          end
        end

        before(:create) do |question, evaluator|
          if question.question_page_id.nil? and !question.hidden
            qp = create(:question_page, decision_aid_id: question.decision_aid_id, section: "quiz")
            question.question_page_id = qp.id
          end
        end
      end
    end

    factory :number_question do
      question_response_type Question.question_response_types[:number]
      question_response_style 4

      factory :demo_number_question do
        question_type 0

        after(:build) do |question, evalutor|
          if question.decision_aid
            question.initialize_order(question.order_scope.count)
          end
        end

        before(:create) do |question, evaluator|
          if question.question_page_id.nil? and !question.hidden
            qp = create(:question_page, decision_aid_id: question.decision_aid_id, section: "about")
            question.question_page_id = qp.id
          end
        end
      end

      factory :quiz_number_question do
        question_type 0

        after(:build) do |question, evalutor|
          if question.decision_aid
            question.initialize_order(question.order_scope.count)
          end
        end

        before(:create) do |question, evaluator|
          if question.question_page_id.nil? and !question.hidden
            qp = create(:question_page, decision_aid_id: question.decision_aid_id, section: "quiz")
            question.question_page_id = qp.id
          end
        end
      end
    end

    factory :lookup_table_question do
      question_response_type Question.question_response_types[:lookup_table]
      question_response_style 5
      hidden true

      factory :demo_lookup_table_question do
        question_type 0

        after(:build) do |question, evalutor|
          if question.decision_aid
            question.initialize_order(question.order_scope.count)
          end
        end
      end
    end
  end
end
