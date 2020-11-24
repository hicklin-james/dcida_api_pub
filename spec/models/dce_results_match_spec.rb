# == Schema Information
#
# Table name: dce_results_matches
#
#  id                   :integer          not null, primary key
#  decision_aid_id      :integer
#  response_combination :integer          is an Array
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  option_match_hash    :json
#

require "rails_helper"

RSpec.describe DceResultsMatch, :type => :model do
  let (:decision_aid) { create(:full_decision_aid, slug: "test_decision_aid") }

  describe "validations" do
    it "shouldn't save if the decision aid is empty" do
      m = build(:dce_results_match,
                response_combination: [1,2,3,4,5], 
                option_match_hash: [
                  {question_response_ids: [], option_id: decision_aid.options.first.id}
                ])
      expect(m.save).to eq false
      expect(m.errors.messages).to have_key :decision_aid_id
    end

    it "shouldn't save if response_combination is empty" do
      m = build(:dce_results_match,
                decision_aid_id: decision_aid.id,
                option_match_hash: [
                  {question_response_ids: [], option_id: decision_aid.options.first.id}
                ])
      expect(m.save).to eq false
      expect(m.errors.messages).to have_key :response_combination
    end

    it "shouldn't save if the option_match_hash is empty" do
      m = build(:dce_results_match,
                decision_aid_id: decision_aid.id)
      expect(m.save).to eq false
      expect(m.errors.messages).to have_key :option_match_hash
    end

    it "shouldn't save if multiple results matches have the same response combination within the decision aid" do
      create(:dce_results_match,
              decision_aid_id: decision_aid.id,
              response_combination: [1,2,3,4,5],
              option_match_hash: [
                {question_response_ids: [], option_id: decision_aid.options.first.id}
              ])
      m = build(:dce_results_match,
                decision_aid_id: decision_aid.id,
                response_combination: [1,2,3,4,5],
                option_match_hash: [
                  {question_response_ids: [], option_id: decision_aid.options.first.id}
                ])
      expect(m.save).to eq false
      expect(m.errors.messages).to have_key :response_combination
    end

    it "should save if all validations pass" do
      m = build(:dce_results_match,
                decision_aid_id: decision_aid.id,
                response_combination: [1,2,3,4,5],
                option_match_hash: [
                  {question_response_ids: [], option_id: decision_aid.options.first.id}
                ])
      expect(m.save).to eq true
    end

  end

end
