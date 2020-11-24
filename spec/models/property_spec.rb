# == Schema Information
#
# Table name: properties
#
#  id                              :integer          not null, primary key
#  title                           :string
#  selection_about                 :text
#  long_about                      :text
#  decision_aid_id                 :integer          not null
#  created_by_user_id              :integer
#  updated_by_user_id              :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  selection_about_published       :text
#  long_about_published            :text
#  property_order                  :integer
#  property_levels_count           :integer          default(0), not null
#  short_label                     :string
#  is_property_weighable           :boolean          default(TRUE)
#  are_option_properties_weighable :boolean          default(TRUE)
#  property_group_title            :string
#  backend_identifier              :string
#

require "rails_helper"

RSpec.describe Property, :type => :model do
  let (:decision_aid) { create(:basic_decision_aid) }

  describe "validations" do
    it "fails to create a property when the decision aid is nil" do
      prop = build(:property, decision_aid: nil)
      expect(prop.save).to be false
    end

    it "fails to create a property when the title is nil" do
      prop = build(:property, decision_aid: decision_aid, title: nil)
      expect(prop.save).to be false
    end

    it "fails to create a property when property_levels don't have unique ids" do
      property = create(:property, decision_aid: decision_aid)
      property_level_attrs = [
        FactoryGirl.attributes_for(:property_level, property_id: property.id, level_id: 1, decision_aid_id: decision_aid.id),
        FactoryGirl.attributes_for(:property_level, property_id: property.id, level_id: 1, decision_aid_id: decision_aid.id)
      ]
      property.property_levels_attributes = property_level_attrs
      expect(property.save).to be false
      expect(property.errors.messages).to have_key :property_levels

    end

    it "creates when property is not yet created and property_level_attributes exist in params" do
      property = build(:property, decision_aid: decision_aid)
      property_level_attrs = [
        FactoryGirl.attributes_for(:property_level, level_id: 1, decision_aid_id: decision_aid.id),
        FactoryGirl.attributes_for(:property_level, level_id: 2, decision_aid_id: decision_aid.id)
      ]
      property.property_levels_attributes = property_level_attrs
      expect(property.save).to be true
    end
  end

  describe "callbacks" do
    let (:property) { create(:property, decision_aid: decision_aid) }
    
    it "publishes accordion values after saving" do
      expect(property.selection_about_published).to eq(property.selection_about)
      expect(property.long_about_published).to eq(property.long_about)
    end
  end

  describe "ordering" do
    let (:properties) {create_list(:property, 5, decision_aid: decision_aid)}

    it "should be ordered from 1 to 5" do
      expect(properties.length).to eq(5)
      properties.each_with_index do |property, index|
        expect(property.property_order).to eq(index + 1)
      end
    end

    it "should change the ordering when change_order is called" do
      property_to_change = properties.first
      property_to_change.change_order(5)
      expect(property_to_change.property_order).to eq(5)
      properties.each do |p|
        p.reload
        expect(p.property_order).to be <= 5
      end
      expect(properties.map(&:property_order).uniq.length).to eq(properties.length)
    end

    it "should correct the ordering when a property is deleted" do
      property_to_delete = properties.delete_at(2)
      property_to_delete.destroy
      properties.each do |p|
        p.reload
        expect(p.property_order).to be <= 4
      end
      expect(properties.map(&:property_order).uniq.length).to eq(properties.length)
    end
  end

  describe "associations" do
    let (:property) { create(:property, decision_aid: decision_aid) }

    it "destroys option properties on destroy" do
      o = create(:option, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id)
      op = create(:option_property, decision_aid: decision_aid, property: property, option: o)
      expect(property.reload.option_properties).to include(op)
      expect(OptionProperty.exists?(op.id)).to be true
      property.destroy
      expect(OptionProperty.exists?(op.id)).to be false
    end

    it "destroys property_levels on destroy" do
      pl = create(:property_level, level_id: 1, property_id: property.id, decision_aid_id: decision_aid.id)
      expect(property.reload.property_levels).to include(pl)
      expect(PropertyLevel.exists?(pl.id)).to be true
      property.destroy
      expect(PropertyLevel.exists?(pl.id)).to be false
    end
  end

  describe "injectable" do
    it_should_behave_like "injectable", :property, :property
  end

  describe "has_attached_items" do
    it_should_behave_like "has_attached_items", :property, :property
  end

  describe "user_stamps" do
    it_behaves_like "user_stamps" do
      let (:item) { create(:property, decision_aid_id: decision_aid.id) }
    end
  end

  describe "methods" do
    let (:property) { create(:property, decision_aid: decision_aid) }

    describe ".clone_property" do
      it "should clone a valid property" do
        property.reload
        expect(property.valid?).to be true
        expect{property.clone_property(decision_aid)}
          .to change{decision_aid.reload.properties_count}.by(1)
      end

      it "should set the cloned property's order to the initial property input plus one" do
        r = property.clone_property(decision_aid)
        expect(r).to have_key :property
        expect(r[:property]).to respond_to "property_order"
        expect(r[:property].property_order).to be(property.property_order + 1)
      end

      it "should fail to clone an invalid property" do
        property.decision_aid_id = nil
        expect(property.valid?).to be false
        r = property.clone_property(decision_aid)
        expect(r).to have_key(:errors)
      end

      it "should clone property levels as well" do
        level = create(:property_level, property_id: property.id, level_id: 1, decision_aid_id: decision_aid.id)
        r = property.reload.clone_property(decision_aid)
        expect(r).to have_key :property
        expect(r[:property].property_levels.length).to eq property.reload.property_levels.length
      end
    end
  end
end
