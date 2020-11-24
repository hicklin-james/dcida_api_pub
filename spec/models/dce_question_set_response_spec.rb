# == Schema Information
#
# Table name: dce_question_set_responses
#
#  id                  :integer          not null, primary key
#  question_set        :integer
#  response_value      :integer
#  property_level_hash :json
#  decision_aid_id     :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  block_number        :integer          default(1), not null
#  is_opt_out          :boolean          default(FALSE)
#  dce_question_set_id :integer
#

require "rails_helper"

RSpec.describe DceQuestionSetResponse, :type => :model do
  let (:decision_aid) { create(:full_decision_aid, slug: "test_decision_aid") }

  describe "validations" do
    it "shouldn't save if question_set is missing" do
      dqsr = build(:dce_question_set_response,
                    response_value: 1,
                    property_level_hash: {1 => 1},
                    decision_aid_id: decision_aid.id)
      expect(dqsr.save).to eq false
      expect(dqsr.errors.messages).to have_key :question_set
    end

    it "shouldn't save if response_value is missing" do
      dqsr = build(:dce_question_set_response,
                    question_set: 1,
                    property_level_hash: {1 => 1},
                    decision_aid_id: decision_aid.id)
      expect(dqsr.save).to eq false
      expect(dqsr.errors.messages).to have_key :response_value
    end

    it "shouldn't save if decision_aid_id is missing" do
      dqsr = build(:dce_question_set_response,
                    question_set: 1,
                    response_value: 1,
                    property_level_hash: {1 => 1})
      expect(dqsr.save).to eq false
      expect(dqsr.errors.messages).to have_key :decision_aid_id
    end

    it "shouldn't save if property_level_hash is missing" do
      dqsr = build(:dce_question_set_response,
                    question_set: 1,
                    response_value: 1,
                    decision_aid_id: decision_aid.id)
      expect(dqsr.save).to eq false
      expect(dqsr.errors.messages).to have_key :property_level_hash
    end

    it "shouldn't save if response_value is not unique to decision aid and question set" do
      create(:dce_question_set_response,
              question_set: 1,
              response_value: 1,
              decision_aid_id: decision_aid.id,
              property_level_hash: {1 => 1})
      dqsr = build(:dce_question_set_response,
                    question_set: 1,
                    response_value: 1,
                    property_level_hash: {1 => 1},
                    decision_aid_id: decision_aid.id)
      expect(dqsr.save).to eq false
      expect(dqsr.errors.messages).to have_key :response_value
    end

    it "should save if all validations pass" do
      dqsr = build(:dce_question_set_response,
                    question_set: 1,
                    response_value: 1,
                    property_level_hash: {1 => 1},
                    decision_aid_id: decision_aid.id)
      expect(dqsr.save).to eq true
    end
  end
end
