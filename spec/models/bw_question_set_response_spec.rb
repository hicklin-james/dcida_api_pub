# == Schema Information
#
# Table name: bw_question_set_responses
#
#  id                 :integer          not null, primary key
#  question_set       :integer
#  property_level_ids :integer          is an Array
#  decision_aid_id    :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  block_number       :integer          default(1), not null
#

require "rails_helper"

RSpec.describe BwQuestionSetResponse, :type => :model do
  let (:decision_aid) { create(:basic_decision_aid, slug: "test_decision_aid") }

  describe "validations" do
    it "should fail to save if the decision_aid_id is missing" do
      b = build(:bw_question_set_response, property_level_ids: [1,2,3], question_set: 1)
      expect(b.save).to be false
      expect(b.errors.messages).to have_key :decision_aid_id
    end

    it "should fail to save if the property_level_ids is missing" do
      b = build(:bw_question_set_response, decision_aid_id: decision_aid.id, question_set: 1)
      expect(b.save).to be false
      expect(b.errors.messages).to have_key :property_level_ids
    end

    it "should fail to save if the question_set is missing" do
      b = build(:bw_question_set_response, decision_aid_id: decision_aid.id, property_level_ids: [1,2,3])
      expect(b.save).to be false
      expect(b.errors.messages).to have_key :question_set
    end

    it "should fail to save if the question_set is not unique to the decision aid" do
      create(:bw_question_set_response, question_set: 1, decision_aid_id: decision_aid.id, property_level_ids: [1,2,3])
      b = build(:bw_question_set_response, question_set: 1, decision_aid_id: decision_aid.id, property_level_ids: [1,2,3])
      expect(b.save).to be false
      expect(b.errors.messages).to have_key :question_set
    end

    it "should save if all attributes are valid" do
      b = build(:bw_question_set_response, question_set: 1, decision_aid_id: decision_aid.id, property_level_ids: [1,2,3])
      expect(b.save).to be true
    end
  end

  describe "methods" do
    describe ".property_levels" do
      let (:prop) { create(:property, decision_aid_id: decision_aid.id) }
      let (:pl1) { create(:property_level, property_id: prop.id, level_id: 1, decision_aid_id: decision_aid.id) }
      let (:pl2) { create(:property_level, property_id: prop.id, level_id: 2, decision_aid_id: decision_aid.id) }
      let (:b) {  create(:bw_question_set_response, question_set: 1, decision_aid_id: decision_aid.id, property_level_ids: [pl1.id, pl2.id]) }

      it "should return an array of property levels that correspond to the property_level_ids" do
        pls = b.property_levels.pluck(:id)
        expect(pls).to include(pl1.id)
        expect(pls).to include(pl2.id)
      end

      it "should include a property_title method" do
        pls = b.property_levels
        expect(pls.first).to respond_to :property_title
      end
    end
  end

end
