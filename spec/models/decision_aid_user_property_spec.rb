# == Schema Information
#
# Table name: decision_aid_user_properties
#
#  id                    :integer          not null, primary key
#  property_id           :integer          not null
#  decision_aid_user_id  :integer          not null
#  weight                :integer          default(50)
#  order                 :integer          not null
#  color                 :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  traditional_value     :float
#  traditional_option_id :integer
#

require "rails_helper"

RSpec.describe DecisionAidUserProperty, :type => :model do
  let (:decision_aid) { create(:full_decision_aid, slug: "test_decision_aid") }
  let (:decision_aid_user) { create(:decision_aid_user, decision_aid_id: decision_aid.id) }
  let (:property) { create(:property, decision_aid_id: decision_aid.id) }

  describe "validations" do
    let (:decision_aid) { create(:basic_decision_aid, slug: "test_decision_aid") }
    it "should fail to save if decision_aid_user_id is missing" do
      dap = build(:decision_aid_user_property)
      expect(dap.save).to be false
      expect(dap.errors.messages).to have_key :decision_aid_user_id
    end

    it "should fail to save if property_id is missing" do
      dap = build(:decision_aid_user_property, decision_aid_user_id: decision_aid_user.id)
      expect(dap.save).to be false
      expect(dap.errors.messages).to have_key :property_id
    end

    it "should fail to save if order is missing" do
      dap = build(:decision_aid_user_property, order: nil, decision_aid_user_id: decision_aid_user.id, property_id: property.id)
      expect(dap.save).to be false
      expect(dap.errors.messages).to have_key :order
    end

    it "should fail to save if color is missing" do
      dap = build(:decision_aid_user_property, color: nil, decision_aid_user_id: decision_aid_user.id, property_id: property.id)
      expect(dap.save).to be false
      expect(dap.errors.messages).to have_key :color
    end

    # it "should fail to save if weight is greater than 100" do
    #   dap = build(:decision_aid_user_property, weight: 101, decision_aid_user_id: decision_aid_user.id, property_id: property.id)
    #   expect(dap.save).to be false
    #   expect(dap.errors.messages).to have_key :weight
    # end

    # it "should fail to save if weight is less than 1" do
    #   dap = build(:decision_aid_user_property, weight: 0, decision_aid_user_id: decision_aid_user.id, property_id: property.id)
    #   expect(dap.save).to be false
    #   expect(dap.errors.messages).to have_key :weight
    # end

    it "should fail if decision_aid_user_property already exists with decision_aid_user_id and property_id" do
      create(:decision_aid_user_property, decision_aid_user_id: decision_aid_user.id, property_id: property.id)
      dap = build(:decision_aid_user_property, decision_aid_user_id: decision_aid_user.id, property_id: property.id)
      expect(dap.save).to be false
      expect(dap.errors.messages).to have_key :property_id
    end

    it "should save if all required attributes exist" do
      dap = build(:decision_aid_user_property, weight: 50, decision_aid_user_id: decision_aid_user.id, property_id: property.id)
      expect(dap.save).to be true
    end
  end

  describe "counters" do
    it "should increase the decision_aid_user_properties_count on create" do
      expect{create(:decision_aid_user_property, weight: 50, decision_aid_user_id: decision_aid_user.id, property_id: property.id)}
        .to change{decision_aid_user.reload.decision_aid_user_properties_count}.by 1
    end

    it "should decrease the decision_aid_user_properties_count on delete" do
      dar = create(:decision_aid_user_property, weight: 50, decision_aid_user_id: decision_aid_user.id, property_id: property.id)
      expect{dar.destroy}.to change{decision_aid_user.reload.decision_aid_user_properties_count}.by -1
    end
  end

  describe "methods" do
    describe "::batch_create_user_properties" do
      it "should create user properties in props hash" do
        props = []
        decision_aid.properties.each do |prop|
          props.push FactoryGirl.attributes_for(:decision_aid_user_property, decision_aid_user_id: decision_aid_user.id, property_id: prop.id)
        end
        expect(props.length).to be > 0
        expect{DecisionAidUserProperty.batch_create_user_properties(props)}
          .to change{decision_aid_user.reload.decision_aid_user_properties_count}.by decision_aid.properties_count
      end

      it "should return an array of newly created user properties" do
        props = []
        decision_aid.properties.each do |prop|
          props.push FactoryGirl.attributes_for(:decision_aid_user_property, decision_aid_user_id: decision_aid_user.id, property_id: prop.id)
        end
        expect(props.length).to be > 0
        r = DecisionAidUserProperty.batch_create_user_properties(props)
        expect(r.length).to be decision_aid.properties_count
      end
    end

    describe "::batch_save_user_properties" do
      it "should save all the user properties in the params" do
        props = []
        decision_aid.properties.each do |prop|
          props.push build(:decision_aid_user_property, decision_aid_user_id: decision_aid_user.id, property_id: prop.id)
        end
        expect(props.length).to be > 0
        props.each do |prop|
          expect(prop.new_record?).to be true
        end
        DecisionAidUserProperty.batch_save_user_properties(props)
        props.each do |prop|
          expect(prop.new_record?).to be false
        end
      end
    end

    describe "::batch_delete_user_properties" do
      it "should delete the user properties in the params" do
        props = []
        decision_aid.properties.each do |prop|
          props.push create(:decision_aid_user_property, decision_aid_user_id: decision_aid_user.id, property_id: prop.id)
        end
        expect(props.length).to be > 0
        expect{DecisionAidUserProperty.batch_delete_user_properties(props)}
          .to change{DecisionAidUserProperty.count}.by -decision_aid.properties_count
      end
    end
  end
end
