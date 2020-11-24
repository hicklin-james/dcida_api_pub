# == Schema Information
#
# Table name: decision_aid_user_option_properties
#
#  id                   :integer          not null, primary key
#  option_property_id   :integer          not null
#  option_id            :integer          not null
#  property_id          :integer          not null
#  decision_aid_user_id :integer          not null
#  value                :float            not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

require "rails_helper"

RSpec.describe DecisionAidUserOptionProperty, :type => :model do
  let (:decision_aid) { create(:full_decision_aid, slug: "test_decision_aid") }
  let (:decision_aid_user) { create(:decision_aid_user, decision_aid_id: decision_aid.id) }
  let (:option) { create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id) }
  let (:property) { create(:property, decision_aid_id: decision_aid.id) }
  let (:option_property) { create(:option_property, option_id: option.id, property_id: property.id, decision_aid_id: decision_aid.id) }

  describe "validations" do
    it "should fail to save if option_id is missing" do
      dauop = build(:decision_aid_user_option_property)
      expect(dauop.save).to be false
      expect(dauop.errors.messages).to have_key :option_id
    end

    it "should fail to save if property_id is missing" do
      dauop = build(:decision_aid_user_option_property)
      expect(dauop.save).to be false
      expect(dauop.errors.messages).to have_key :property_id
    end

    it "should fail to save if option_property_id is missing" do
      dauop = build(:decision_aid_user_option_property)
      expect(dauop.save).to be false
      expect(dauop.errors.messages).to have_key :option_property_id
    end

    it "should fail to save if decision_aid_user_id is missing" do
      dauop = build(:decision_aid_user_option_property)
      expect(dauop.save).to be false
      expect(dauop.errors.messages).to have_key :decision_aid_user_id
    end

    it "should fail to save if value is missing" do
      dauop = build(:decision_aid_user_option_property, value: nil)
      expect(dauop.save).to be false
      expect(dauop.errors.messages).to have_key :value
    end

    it "should fail to save if value is greater than 10" do
      dauop = build(:decision_aid_user_option_property, value: 11)
      expect(dauop.save).to be false
      expect(dauop.errors.messages).to have_key :value
    end

    it "should fail to save if value is less than 0" do
      dauop = build(:decision_aid_user_option_property, value: -1)
      expect(dauop.save).to be false
      expect(dauop.errors.messages).to have_key :value
    end

    it "should save if all attributes are there" do
      dauop = build(:decision_aid_user_option_property, value: 5, option_id: option.id, property_id: property.id, option_property_id: option_property.id, decision_aid_user_id: decision_aid_user.id)
    end
  end

  describe "counters" do
    it "should increase the decision_aid_user_option_properties_count on create" do
      expect{create(:decision_aid_user_option_property, value: 5, option_id: option.id, property_id: property.id, option_property_id: option_property.id, decision_aid_user_id: decision_aid_user.id)}
        .to change{decision_aid_user.reload.decision_aid_user_option_properties_count}.by 1
    end

    it "should decrease the decision_aid_user_option_properties_count on delete" do
      dar = create(:decision_aid_user_option_property, value: 5, option_id: option.id, property_id: property.id, option_property_id: option_property.id, decision_aid_user_id: decision_aid_user.id)
      expect{dar.destroy}.to change{decision_aid_user.reload.decision_aid_user_option_properties_count}.by -1
    end
  end

  describe "methods" do
    describe "::update_values" do
      before do
        decision_aid.option_properties.each do |op|
          create(:decision_aid_user_option_property, value: 5, option_id: op.option_id, property_id: op.property_id, option_property_id: op.id, decision_aid_user_id: decision_aid_user.id)
        end
      end

      it "should update the values from the update_params_hash" do
        dauops = DecisionAidUserOptionProperty.where(decision_aid_user_id: decision_aid_user.id)
        op_value = 6
        expect(dauops.length).to be > 0
        params_hash = {}
        dauops.each do |dauop|
          params_hash[dauop.id] = {"value" => op_value}
        end
        ops = []
        DecisionAidUserOptionProperty.update_values(params_hash, ops, decision_aid_user.id)
        expect(ops.length).to be > 0
        expect(ops.length).to eq params_hash.length
        ops.each do |op|
          expect(op.value).to eq op_value
        end
      end

      it "should raise an exception if an id in the params hash is not a valid id" do
        dauops = DecisionAidUserOptionProperty.where(decision_aid_user_id: decision_aid_user.id)
        op_value = 6
        params_hash = {0 => {"value" => 6}}
        expect{DecisionAidUserOptionProperty.update_values(params_hash, [], decision_aid_user.id)}
          .to raise_error(Exceptions::InvalidParams)
      end
    end
  end
end
