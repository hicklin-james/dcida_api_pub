# == Schema Information
#
# Table name: decision_aid_user_responses
#
#  id                    :integer          not null, primary key
#  question_response_id  :integer
#  response_value        :text
#  question_id           :integer          not null
#  decision_aid_user_id  :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  number_response_value :float
#  lookup_table_value    :float
#  option_id             :integer
#  json_response_value   :json
#  selected_unit         :string
#

require "rails_helper"

RSpec.describe DecisionAidUserResponse, :type => :model do
  let (:decision_aid) { create(:full_decision_aid, slug: "test_decision_aid") }
  let (:decision_aid_user) { create(:decision_aid_user, decision_aid_id: decision_aid.id) }
  let (:text_question) { create(:demo_text_question, decision_aid_id: decision_aid.id) }
  let (:radio_question) { create(:demo_radio_question, decision_aid_id: decision_aid.id) }

  describe "validations" do
    it "should fail to save if decision_aid_user is nil" do
      dar = build(:decision_aid_user_response, question_id: text_question.id)
      expect(dar.save).to be false
      expect(dar.errors.messages).to have_key :decision_aid_user_id
    end

    it "should fail to save when multiple responses have the same question_id in the decision_aid_user_id scope" do
      create(:decision_aid_user_response, question_id: text_question.id, decision_aid_user_id: decision_aid_user.id)
      dar = build(:decision_aid_user_response, question_id: text_question.id, decision_aid_user_id: decision_aid_user.id)
      expect(dar.save).to be false
      expect(dar.errors.messages).to have_key :question_id
    end

    it "should not allow multiple responses with the same question response id within a decision aid user" do
      create(:decision_aid_user_response, question_id: radio_question.id, question_response_id: radio_question.question_responses.first.id, decision_aid_user_id: decision_aid_user.id)
      dar = build(:decision_aid_user_response, question_id: radio_question.id, question_response_id: radio_question.question_responses.first.id, decision_aid_user_id: decision_aid_user.id)
      expect(dar.save).to be false
      expect(dar.errors.messages).to have_key :question_response_id
    end

    it "should allow multiple responses with the same question_response_id as long as they are different decision aid users" do
      dau2 = create(:decision_aid_user, decision_aid_id: decision_aid.id)
      create(:decision_aid_user_response, question_id: radio_question.id, question_response_id: radio_question.question_responses.first.id, decision_aid_user_id: dau2.id)
      dar = build(:decision_aid_user_response, question_id: radio_question.id, question_response_id: radio_question.question_responses.first.id, decision_aid_user_id: decision_aid_user.id)
      expect(dar.save).to be true
    end

    it "should allow multiple responses with the same question_id as long as they are different decision aid users" do
      dau2 = create(:decision_aid_user, decision_aid_id: decision_aid.id)
      create(:decision_aid_user_response, question_id: text_question.id, decision_aid_user_id: dau2.id)
      dar = build(:decision_aid_user_response, question_id: text_question.id, decision_aid_user_id: decision_aid_user.id)
      expect(dar.save).to be true
    end

    it "should fail to save if the number_response_value is not a number" do
      dar = build(:decision_aid_user_response, question_id: text_question.id, decision_aid_user_id: decision_aid_user.id, number_response_value: "non-number")
      expect(dar.save).to eq false
      expect(dar.errors.messages).to have_key :number_response_value
    end
  end

  describe "counters" do
    it "should increase the decision_aid_user_responses_count on create" do
      expect{create(:decision_aid_user_response, question_id: text_question.id, decision_aid_user_id: decision_aid_user.id)}
        .to change{decision_aid_user.reload.decision_aid_user_responses_count}.by 1
    end

    it "should decrease the decision_aid_user_responses_count on delete" do
      dar = create(:decision_aid_user_response, question_id: text_question.id, decision_aid_user_id: decision_aid_user.id)
      expect{dar.destroy}.to change{decision_aid_user.reload.decision_aid_user_responses_count}.by -1
    end
  end

end
