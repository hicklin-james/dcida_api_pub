# == Schema Information
#
# Table name: decision_aid_user_dce_question_set_responses
#
#  id                           :integer          not null, primary key
#  dce_question_set_response_id :integer
#  decision_aid_user_id         :integer
#  question_set                 :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  fallback_question_set_id     :integer
#  option_confirmed             :boolean
#

require "rails_helper"

RSpec.describe DecisionAidUserDceQuestionSetResponse, :type => :model do
  let (:decision_aid) { create(:full_decision_aid, slug: "test_decision_aid") }
  let (:decision_aid_user) { create(:decision_aid_user, decision_aid_id: decision_aid.id) }
  let (:dce_question_set_response) { create(:dce_question_set_response, question_set: 1, response_value: 1, property_level_hash: {1 => 1}, decision_aid_id: decision_aid.id) }

  describe "validations" do
    it "should fail to save if the decision_aid_user_id is missing" do
      dqsr = build(:decision_aid_user_dce_question_set_response, question_set: 1, dce_question_set_response_id: dce_question_set_response.id)
      expect(dqsr.save).to be false
      expect(dqsr.errors.messages).to have_key :decision_aid_user_id
    end

    it "should fail to save if the question_set is missing" do
      dqsr = build(:decision_aid_user_dce_question_set_response, decision_aid_user_id: decision_aid_user.id, dce_question_set_response_id: dce_question_set_response.id)
      expect(dqsr.save).to be false
      expect(dqsr.errors.messages).to have_key :question_set
    end

    it "should fail to save if the dce_question_set_response_id is missing" do
      dqsr = build(:decision_aid_user_dce_question_set_response, decision_aid_user_id: decision_aid_user.id, question_set: 1)
      expect(dqsr.save).to be false
      expect(dqsr.errors.messages).to have_key :dce_question_set_response_id
    end
  end
end
