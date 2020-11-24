# == Schema Information
#
# Table name: property_levels
#
#  id                    :integer          not null, primary key
#  information           :text
#  information_published :text
#  level_id              :integer
#  property_id           :integer          not null
#  created_by_user_id    :integer
#  updated_by_user_id    :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  decision_aid_id       :integer
#

require 'rails_helper'

RSpec.describe PropertyLevel, type: :model do
  
  let (:decision_aid) { create(:basic_decision_aid) }
  let(:property) { create(:property, decision_aid_id: decision_aid.id) }

  describe "validations" do
    it "shouldn't save if property_id is missing" do
      property_level = build(:property_level, level_id: property.property_levels.length, decision_aid_id: decision_aid.id)
      expect(property_level.save).to be false
      expect(property_level.errors.messages).to have_key :property
    end

    it "shouldn't save if level_id is missing" do
      property_level = build(:property_level, property_id: property.id, decision_aid_id: decision_aid.id)
      expect(property_level.save).to be false
      expect(property_level.errors.messages).to have_key :level_id
    end

    it "shouldn't save if decision_aid_id is missing" do
      property_level = build(:property_level, property_id: property.id)
      expect(property_level.save).to be false
      expect(property_level.errors.messages).to have_key :decision_aid_id
    end

    it "should save if all attributes exist and no validation errors are triggerd" do
      property_level = build(:property_level, level_id: property.property_levels.length, property_id: property.id, decision_aid_id: decision_aid.id)
      expect(property_level.save).to be true
    end
  end

  describe "has_attached_items" do
    it_should_behave_like "has_attached_items", :property_level, :property_level
  end

  describe "injectable" do
    it_should_behave_like "injectable", :property_level, :property_level
  end

  describe "user_stamps" do
    it_behaves_like "user_stamps" do
      let (:item) { create(:property_level, level_id: property.property_levels.length, property_id: property.id, decision_aid_id: decision_aid.id) }
    end
  end

  describe "scopes" do
    it "should be ordered based on level_id attr when using ordered scope" do
      pl2 = create(:property_level, level_id: 1, property_id: property.id, decision_aid_id: decision_aid.id)
      pl1 = create(:property_level, level_id: 2, property_id: property.id, decision_aid_id: decision_aid.id)

      ordered_levels = property.reload.property_levels
      expect(ordered_levels.first).to eq pl2
      expect(ordered_levels.second).to eq pl1
    end
  end
end
