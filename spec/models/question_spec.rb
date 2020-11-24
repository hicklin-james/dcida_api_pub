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

require "rails_helper"

RSpec.describe Question, :type => :model do
  let (:decision_aid) { create(:basic_decision_aid) }
  let (:response_attrs) { FactoryGirl.attributes_for(:question_response, decision_aid_id: decision_aid.id, question_response_order: 1) }
  let (:radio_question_attrs) { FactoryGirl.attributes_for(:demo_radio_question, decision_aid_id: decision_aid.id, question_responses_attributes: [response_attrs], question_order: 1)}
  let (:demo_question_page) { create(:question_page, decision_aid_id: decision_aid.id, section: "about") }
  let (:quiz_question_page) { create(:question_page, decision_aid_id: decision_aid.id, section: "quiz") }

  describe "validations" do
    describe "general" do
      it "fails to save when the decision aid is missing" do
        question = build(:demo_radio_question, decision_aid: nil, question_responses_attributes: [response_attrs], question_page_id: demo_question_page.id)
        expect(question.save).to be false
        expect(question.errors.messages).to have_key :decision_aid_id
      end

      it "fails to save when the question type is missing" do
        question = build(:demo_radio_question, question_type: nil, question_responses_attributes: [response_attrs], question_page_id: demo_question_page.id)
        expect(question.save).to be false
        expect(question.errors.messages).to have_key :question_type
      end

      it "fails to save when the question response type is missing" do
        question = build(:demo_radio_question, question_response_type: nil, question_responses_attributes: [response_attrs], question_page_id: demo_question_page.id)
        expect(question.save).to be false
        expect(question.errors.messages).to have_key :question_response_type
      end

      it "fails to save when the question order is missing" do
        question = build(:demo_radio_question, question_order: nil, question_responses_attributes: [response_attrs], question_page_id: demo_question_page.id)
        expect(question.save).to be false
        expect(question.errors.messages).to have_key :question_order
      end

      it "fails to save when the question_response_style is missing" do
        question = build(:demo_radio_question, question_response_style: nil, question_responses_attributes: [response_attrs], question_page_id: demo_question_page.id)
        expect(question.save).to be false
        expect(question.errors.messages).to have_key :question_response_style
      end
    end

    describe "radio" do
      it "fails to save when there isn't at least one question response" do
        question = build(:demo_radio_question, decision_aid: decision_aid, question_responses_attributes: [], question_page_id: demo_question_page.id)
        expect(question.save).to be false
        expect(question.errors.messages).to have_key :question_responses
      end

      it "saves when all the required attributes are there" do
        question = build(:demo_radio_question, decision_aid: decision_aid, question_responses_attributes: [response_attrs], question_page_id: demo_question_page.id)
        expect(question.save!).to be true
      end

      it "saves hidden questions" do
        question = build(:demo_radio_question, decision_aid: decision_aid, question_responses_attributes: [response_attrs], hidden: true)
        expect(question.save).to be true
      end
    end

    describe "text" do
      it "saves when all the required attributes are there" do
        question = build(:demo_text_question, decision_aid: decision_aid, question_page_id: demo_question_page.id)
        expect(question.save).to be true
      end

      it "fails to save if text question is hidden" do
        question = build(:demo_text_question, decision_aid_id: decision_aid.id, hidden: true)
        expect(question.save).to eq false
        expect(question.errors.messages).to have_key :hidden
      end
    end

    describe "grid" do
      it "fails to save when there isn't at least one grid question" do
        question = build(:demo_grid_question, decision_aid: decision_aid, question_page_id: demo_question_page.id)
        expect(question.save).to be false
        expect(question.errors.messages).to have_key :grid_questions
      end

      it "fails to save when the grid questions don't have any responses" do
        radio_question_attrs[:question_responses_attributes] = []
        question = build(:demo_grid_question, decision_aid: decision_aid, grid_questions_attributes: [radio_question_attrs], question_page_id: demo_question_page.id)
        expect(question.save).to be false
        expect(question.errors.messages).to have_key :"grid_questions.question_responses"
      end

      it "fails to save when the grid question isn't a radio question" do
        question = build(:demo_grid_question, decision_aid: decision_aid, grid_questions_attributes: [radio_question_attrs], question_page_id: demo_question_page.id)
        expect(question.save).to be true
        q = build(:demo_text_question, decision_aid: decision_aid, question_id: question.id)
        expect(q.save).to be false
        expect(q.errors.messages).to have_key :question_response_type
      end

      it "fails to save if grid question is hidden" do
        question = build(:demo_grid_question, decision_aid: decision_aid, hidden: true, question_page_id: demo_question_page.id)
        expect(question.save).to be false
        expect(question.errors.messages).to have_key :hidden
      end

      it "saves when all the required attributes are there" do
        question = build(:demo_grid_question, decision_aid: decision_aid, grid_questions_attributes: [radio_question_attrs], question_page_id: demo_question_page.id)
        expect(question.save).to be true
      end
    end

    describe "yes/no" do
      let (:yes_no_response_attributes) {[
        FactoryGirl.attributes_for(:question_response, question_response_order: 1, decision_aid: decision_aid, numeric_value: 1),
        FactoryGirl.attributes_for(:question_response, question_response_order: 2, decision_aid: decision_aid, numeric_value: 2)
        ]}

      it "fails to save when there isn't exactly 2 question responses" do
        r1 = FactoryGirl.attributes_for(:question_response, decision_aid_id: decision_aid.id, question_response_order: 1)
        question = build(:demo_yes_no_question, decision_aid: decision_aid, question_responses_attributes: [r1], question_page_id: demo_question_page.id)
        expect(question.save).to be false
        expect(question.errors.messages).to have_key :yes_no_questions
      end

      it "saves when all the required attributes are there" do
        question = build(:demo_yes_no_question, decision_aid_id: decision_aid.id, question_responses_attributes: yes_no_response_attributes, question_page_id: demo_question_page.id)
        expect(question.save).to be true
      end

      it "saves hidden questions" do
        question = build(:demo_yes_no_question, hidden: true, decision_aid_id: decision_aid.id, question_responses_attributes: yes_no_response_attributes)
        expect(question.save).to be true
      end
    end

    describe "number" do
      it "saves when all the required attributes are there" do
        question = build(:demo_number_question, decision_aid_id: decision_aid.id, question_page_id: demo_question_page.id)
        expect(question.save).to be true
      end
    end

    describe "current_treatment" do
      it "fails to save when the sub_decision_id is missing" do
        question = build(:demo_current_treatment_question, decision_aid_id: decision_aid.id, question_page_id: demo_question_page.id)
        expect(question.save).to be false
        expect(question.errors.messages).to have_key :sub_decision_id
      end

      it "saves when all required attributes are there" do
        question = build(:demo_current_treatment_question, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id, question_page_id: demo_question_page.id)
        expect(question.save).to be true
      end
    end

    describe "lookup_table" do
      let (:q1) { create(:demo_radio_question, decision_aid: decision_aid) }
      let (:q2) { create(:demo_radio_question, decision_aid: decision_aid) }

      def create_lookup_json
        json = Hash.new
        index = 0
        q1.question_responses.each do |qrq1|
          json[qrq1.id] = Hash.new
          q2.question_responses.each do |qrq2|
            json[qrq1.id][qrq2.id] = index
            index += 1
          end
        end
        json
      end

      it "fails to save if lookup_table is missing" do
        question = build(:demo_lookup_table_question, decision_aid_id: decision_aid.id)
        expect(question.save).to be false
        expect(question.errors.messages).to have_key :lookup_table
      end

      it "fails to save if two dimensions are the same" do
        question = build(:demo_lookup_table_question, decision_aid_id: decision_aid.id, lookup_table: create_lookup_json, lookup_table_dimensions: [q1.id, q1.id])
        expect(question.save).to be false
        expect(question.errors.messages).to have_key :lookup_table_dimensions
      end

      it "should fail to save if hidden is false" do
        question = build(:demo_lookup_table_question, decision_aid_id: decision_aid.id, lookup_table: create_lookup_json, hidden: false)
        expect(question.save).to be false
        expect(question.errors.messages).to have_key :hidden
      end

      it "should save if all attributes are valid and exist" do
        question = build(:demo_lookup_table_question, decision_aid_id: decision_aid.id, lookup_table: create_lookup_json)
        expect(question.save).to be true
      end
    end
  end

  describe "ordering" do
    describe "quiz questions" do
      let (:quiz_questions) {create_list(:quiz_text_question, 5, decision_aid: decision_aid, question_page_id: quiz_question_page.id)}

      it "should be ordered from 1 to 5" do
        expect(quiz_questions.length).to eq(5)
        quiz_questions.each_with_index do |question, index|
          expect(question.question_order).to eq(index + 1)
        end
      end

      it "should change the ordering when change_order is called" do
        question_to_change = quiz_questions.first
        question_to_change.change_order(5)
        expect(question_to_change.question_order).to eq(5)
        quiz_questions.each do |q|
          q.reload
          expect(q.question_order).to be <= 5
        end
        expect(quiz_questions.map(&:question_order).uniq.length).to eq(quiz_questions.length)
      end

      it "should correct the ordering when a question is deleted" do
        question_to_delete = quiz_questions.delete_at(2)
        question_to_delete.destroy
        quiz_questions.each do |q|
          q.reload
          expect(q.question_order).to be <= 4
        end
        expect(quiz_questions.map(&:question_order).uniq.length).to eq(quiz_questions.length)
      end

      it "shouldn't change order when hidden question is created" do
        expect(quiz_questions.length).to eq(5)
        hidden_question = create(:quiz_radio_question, decision_aid: decision_aid, hidden: true)
        expect(quiz_questions.length).to eq(5)
      end
    end

    describe "demographic questions" do
      let (:demo_questions) {create_list(:demo_text_question, 5, decision_aid: decision_aid, question_page_id: demo_question_page.id)}

      it "should be ordered from 1 to 5" do
        expect(demo_questions.length).to eq(5)
        demo_questions.each_with_index do |question, index|
          expect(question.question_order).to eq(index + 1)
        end
      end

      it "should change the ordering when change_order is called" do
        question_to_change = demo_questions.first
        question_to_change.change_order(5)
        expect(question_to_change.question_order).to eq(5)
        demo_questions.each do |q|
          q.reload
          expect(q.question_order).to be <= 5
        end
        expect(demo_questions.map(&:question_order).uniq.length).to eq(demo_questions.length)
      end

      it "should correct the ordering when a question is deleted" do
        question_to_delete = demo_questions.delete_at(2)
        question_to_delete.destroy
        demo_questions.each do |q|
          q.reload
          expect(q.question_order).to be <= 4
        end
        expect(demo_questions.map(&:question_order).uniq.length).to eq(demo_questions.length)
      end
    end
  end

  describe "has_attached_items" do
    it_should_behave_like "has_attached_items", :question, :demo_text_question
  end

  describe "callbacks" do    
    let (:question) { create(:demo_radio_question, decision_aid: decision_aid) }
    
    it "publishes accordion values after saving" do
      expect(question.question_text_published).to eq(question.question_text)
    end

    it "destroys grid questions if the question response type isn't a grid any more" do
      question = create(:demo_grid_question, decision_aid: decision_aid)
      grid_question_count = question.grid_questions.length
      expect(decision_aid.reload.demographic_questions_count).to eq grid_question_count + 1
      question.question_response_type = "text"
      question.question_response_style = 2
      expect{question.save}.to change{decision_aid.reload.demographic_questions_count}.by -grid_question_count
    end

    it "destroys responses if the question response type isn't radio any more" do
      question = create(:demo_radio_question, decision_aid: decision_aid)
      response_count = question.question_responses.length
      expect(response_count).to be > 0
      expect(decision_aid.reload.question_responses_count).to eq response_count
      question.question_response_type = "text"
      question.question_response_style = 2
      expect{question.save}.to change{decision_aid.reload.question_responses_count}.by -response_count
    end
  end

  describe "associations" do
    let (:question) { create(:demo_radio_question, decision_aid: decision_aid) }

    it "destroys responses on destroy" do
      responses_count = question.question_responses.length
      expect{question.destroy}.to change{QuestionResponse.count}.by(-responses_count)
    end
  end

  describe "methods" do
    # === NOT ALLOWED FOR NOW === #
    
    # describe "clone_question" do
    #   it "should clone a quiz question to a demographic question" do
    #     question = create(:quiz_radio_question, decision_aid: decision_aid)
    #     r = question.clone_question(decision_aid)
    #     expect(r[:error]).to be_nil
    #     cloned_question = r[:question]
    #     expect(cloned_question.question_type).to eq "demographic"
    #   end

    #   it "should clone a radio question and all responses" do
    #     question = create(:quiz_radio_question, decision_aid: decision_aid)
    #     r = question.clone_question(decision_aid)
    #     expect(r[:error]).to be_nil
    #     cloned_question = r[:question]
    #     expect(cloned_question.question_responses.length).to eq(question.question_responses.length)
    #     expect(cloned_question.question_text).to eq(question.question_text)
    #   end

    #   it "should clone a demographic question to a quiz question" do
    #     question = create(:demo_grid_question, decision_aid: decision_aid)
    #     r = question.clone_question(decision_aid)
    #     expect(r[:error]).to be_nil
    #     cloned_question = r[:question]
    #     expect(cloned_question.question_type).to eq "quiz"
    #   end

    #   it "should clone a grid question, all sub questions, and all responses" do
    #     question = create(:demo_grid_question, decision_aid: decision_aid)
    #     r = question.clone_question(decision_aid)
    #     expect(r[:error]).to be_nil
    #     cloned_question = r[:question]
    #     expect(cloned_question.grid_questions.length).to eq(question.grid_questions.length)
    #     cloned_question.grid_questions.each_with_index do |q, i|
    #       initial_question = question.grid_questions[i]
    #       expect(initial_question.question_text).to eq(q.question_text)
    #       q.question_responses.each_with_index do |qr, ii|
    #         initial_question_response = initial_question.question_responses[ii]
    #         expect(initial_question_response.question_response_value).to eq(qr.question_response_value)
    #       end
    #     end
    #   end
    # end

    describe "batch_create_and_update_hidden_responses" do
      let (:q1) { create(:demo_radio_question, decision_aid_id: decision_aid.id) }
      let (:q2) { create(:demo_radio_question, decision_aid_id: decision_aid.id) }
      let (:hidden_radio_question) { create(:question, 
                                      question_type: Question.question_types[:demographic], 
                                      question_response_type: Question.question_response_types[:radio], 
                                      decision_aid_id: decision_aid.id, 
                                      hidden: true, 
                                      question_order: 3,
                                      question_response_style: 0,
                                      response_value_calculation: "[question_#{q1.id}] + [question_#{q2.id}]",
                                      question_responses_attributes: 2.upto(q1.question_responses.length + q2.question_responses.length + 2).each_with_index.map{|i, index| 
                                        FactoryGirl.attributes_for(:question_response, question_response_order: index+1, decision_aid_id: decision_aid.id, numeric_value: i)
                                      })}
      let (:hidden_yes_no_question) { create(:question, 
                                      question_type: Question.question_types[:demographic], 
                                      question_response_type: Question.question_response_types[:yes_no], 
                                      decision_aid_id: decision_aid.id, 
                                      hidden: true, 
                                      question_order: 3,
                                      question_response_style: 6,
                                      response_value_calculation: "[question_#{q1.id}] + [question_#{q2.id}]",
                                      question_responses_attributes: [
                                        FactoryGirl.attributes_for(:question_response, question_response_order: 1, decision_aid_id: decision_aid.id, numeric_value: 2),
                                        FactoryGirl.attributes_for(:question_response, question_response_order: 2, decision_aid_id: decision_aid.id, numeric_value: 3)
                                      ])}
      let (:hidden_numeric_question) { create(:question, 
                                      question_type: Question.question_types[:demographic], 
                                      question_response_type: Question.question_response_types[:number], 
                                      decision_aid_id: decision_aid.id, 
                                      hidden: true, 
                                      question_response_style: 4,
                                      question_order: 3,
                                      response_value_calculation: "[question_#{q1.id}] + [question_#{q2.id}]")}
      let (:decision_aid_user) { create(:decision_aid_user, decision_aid_id: decision_aid.id) }
      let! (:r1) { create(:decision_aid_user_response, decision_aid_user_id: decision_aid_user.id, question_id: q1.id, question_response_id: q1.question_responses.first.id)}
      let! (:r2) { create(:decision_aid_user_response, decision_aid_user_id: decision_aid_user.id, question_id: q2.id, question_response_id: q2.question_responses.first.id)}

      let (:q3) { create(:demo_radio_question, decision_aid: decision_aid) }
      let (:q4) { create(:demo_radio_question, decision_aid: decision_aid) }
      let! (:r3) { create(:decision_aid_user_response, decision_aid_user_id: decision_aid_user.id, question_id: q3.id, question_response_id: q3.question_responses.first.id)}
      let! (:r4) { create(:decision_aid_user_response, decision_aid_user_id: decision_aid_user.id, question_id: q4.id, question_response_id: q4.question_responses.first.id)}
      let (:hidden_lookup_table_question) { create(:demo_lookup_table_question, decision_aid_id: decision_aid.id, lookup_table: create_lookup_json, lookup_table_dimensions: [q3.id, q4.id]) }

      def create_lookup_json
        json = Hash.new
        index = 0
        q3.question_responses.each do |qrq1|
          json[qrq1.id.to_s] = Hash.new
          q4.question_responses.each do |qrq2|
            json[qrq1.id.to_s][qrq2.id.to_s] = index
            index += 1
          end
        end
        json
      end

      it "should add a new response if there isn't one for the question and the question is radio" do
        expect{Question.batch_create_and_update_hidden_responses(Question.where(id: hidden_radio_question.id), decision_aid_user)}
          .to change{DecisionAidUserResponse.count}.by 1
        #expect{hidden_radio_question.calculate_hidden_value(decision_aid_user)}.to change{DecisionAidUserResponse.count}.by 1
      end

      it "should add a new response if there isn't one for the question and the question is numeric" do
        expect{Question.batch_create_and_update_hidden_responses(Question.where(id: hidden_numeric_question.id), decision_aid_user)}
          .to change{DecisionAidUserResponse.count}.by 1
      end

      it "should add a new response if there isn't one for the question and the question is yes/no" do
        expect{Question.batch_create_and_update_hidden_responses(Question.where(id: hidden_yes_no_question.id), decision_aid_user)}
          .to change{DecisionAidUserResponse.count}.by 1
      end

      it "should update an existing numeric response if there is one for the question" do
        r = create(:decision_aid_user_response, decision_aid_user_id: decision_aid_user.id, question_id: hidden_numeric_question.id, number_response_value: 5)
        expect(r.number_response_value).to eq 5
        v = q1.question_responses.first.numeric_value + q2.question_responses.first.numeric_value
        Question.batch_create_and_update_hidden_responses(Question.where(id: hidden_numeric_question.id), decision_aid_user)
        expect(r.reload.number_response_value).to eq v
      end

      it "should update an existing radio response if there is one for the question" do
        r = create(:decision_aid_user_response, decision_aid_user_id: decision_aid_user.id, question_id: hidden_radio_question.id, question_response_id: hidden_radio_question.question_responses.last.id)
        matching_response = hidden_radio_question.question_responses.where(numeric_value: r1.question_response.numeric_value + r2.question_response.numeric_value).first
        v = q1.question_responses.first.numeric_value + q2.question_responses.first.numeric_value
        expect(r.question_response_id).not_to eq matching_response.id
        Question.batch_create_and_update_hidden_responses(Question.where(id: hidden_radio_question.id), decision_aid_user)
        expect(r.reload.question_response_id).to eq matching_response.id
      end

      it "should update an existing yes_no response if there is one for the question" do
        r = create(:decision_aid_user_response, decision_aid_user_id: decision_aid_user.id, question_id: hidden_yes_no_question.id, question_response_id: hidden_yes_no_question.question_responses.last.id)
        matching_response = hidden_yes_no_question.question_responses.where(numeric_value: r1.question_response.numeric_value + r2.question_response.numeric_value).first
        v = q1.question_responses.first.numeric_value + q2.question_responses.first.numeric_value
        expect(r.question_response_id).not_to eq matching_response.id
        Question.batch_create_and_update_hidden_responses(Question.where(id: hidden_yes_no_question.id), decision_aid_user)
        expect(r.reload.question_response_id).to eq matching_response.id
      end

      it "it should set the question_response_id of the new user response as the one with the correct value if the question is radio" do
        v = q1.question_responses.first.numeric_value + q2.question_responses.first.numeric_value
        Question.batch_create_and_update_hidden_responses(Question.where(id: hidden_radio_question.id), decision_aid_user)
        r = DecisionAidUserResponse.where(question_id: hidden_radio_question.id).take
        expect(r.question_response.numeric_value).to eq v
      end

      it "it should set the question_response_id of the new user response as the one with the correct value if the question is yes/no" do
        v = q1.question_responses.first.numeric_value + q2.question_responses.first.numeric_value
        Question.batch_create_and_update_hidden_responses(Question.where(id: hidden_yes_no_question.id), decision_aid_user)
        r = DecisionAidUserResponse.where(question_id: hidden_yes_no_question.id).take
        expect(r.question_response.numeric_value).to eq v
      end

      it "should set the number_response_value of the user response if the question is numeric" do
        v = q1.question_responses.first.numeric_value + q2.question_responses.first.numeric_value
        Question.batch_create_and_update_hidden_responses(Question.where(id: hidden_numeric_question.id), decision_aid_user)
        r = DecisionAidUserResponse.where(question_id: hidden_numeric_question.id).take
        expect(r.number_response_value).to eq v
      end

      it "should create a new response with lookup_table_question" do
        expect{Question.batch_create_and_update_hidden_responses(Question.where(id: hidden_lookup_table_question.id), decision_aid_user)}.to change{DecisionAidUserResponse.count}.by 1
      end

      it "should update an existing lookup_table_question if there is one for the question" do
        expect{Question.batch_create_and_update_hidden_responses(Question.where(id: hidden_yes_no_question.id), decision_aid_user)}.to change{DecisionAidUserResponse.count}.by 1
        r3.question_response_id = q3.question_responses.second.id
        r3.save
        expect{Question.batch_create_and_update_hidden_responses(Question.where(id: hidden_yes_no_question.id), decision_aid_user)}.not_to change{DecisionAidUserResponse.count}
      end

      it "should create a new response with the value from the lookup_table" do
        Question.batch_create_and_update_hidden_responses(Question.where(id: hidden_lookup_table_question.id), decision_aid_user)
        r = DecisionAidUserResponse.where(question_id: hidden_lookup_table_question.id).take
        expect(r.lookup_table_value).to eq 0 # based on create_lookup_json function
      end

      it "should gracefully handle no lookup be creating an empty decision_aid_user_response" do
        hidden_lookup_table_question.lookup_table_dimensions = [000]
        hidden_lookup_table_question.save!
        Question.batch_create_and_update_hidden_responses(Question.where(id: hidden_lookup_table_question.id), decision_aid_user)
        r = DecisionAidUserResponse.where(question_id: hidden_lookup_table_question.id).take
        expect(r.lookup_table_value).to be nil
      end
    end
  end
end
