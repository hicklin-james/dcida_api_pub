# == Schema Information
#
# Table name: options
#
#  id                      :integer          not null, primary key
#  title                   :string           not null
#  label                   :string
#  description             :text
#  summary_text            :text
#  decision_aid_id         :integer          not null
#  created_by_user_id      :integer
#  updated_by_user_id      :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  media_file_id           :integer
#  question_response_array :integer          default([]), is an Array
#  description_published   :text
#  summary_text_published  :text
#  option_order            :integer
#  option_id               :integer
#  has_sub_options         :boolean          not null
#  sub_decision_id         :integer
#  generic_name            :string
#

require "rails_helper"

RSpec.describe Option, :type => :model do
  let (:decision_aid) { create(:basic_decision_aid) }

  describe "validations" do
    it "fails to create an option when the decision aid is nil" do
      option = build(:option, decision_aid: nil)
      expect(option.save).to be false
    end

    it "fails to create an option when the title is nil" do
      option = build(:option, decision_aid: decision_aid, title: nil, sub_decision_id: decision_aid.sub_decisions.first.id)
      expect(option.save).to be false
    end

    it "fails to save if sub_decision_id is missing" do
      option = build(:option, decision_aid: decision_aid, sub_decision_id: nil)
      expect(option.save).to be false
    end

    it "saves when all the required attributes are there" do
      option = build(:option, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id)
      expect(option.save).to be true
    end
  end

  describe "callbacks" do
    let (:option) { create(:option, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id) }
    let (:option_with_sub_options) { create(:option_with_sub_options, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id) }
    
    it "publishes accordion values after saving" do
      expect(option.description_published).to eq(option.description)
      expect(option.summary_text_published).to eq(option.summary_text)
    end
    
    it 'clears out sub options when has_sub_options changes before saving' do
      expect(option_with_sub_options.sub_options.length).to be > 0
      sub_options_length = option_with_sub_options.sub_options.length
      option_with_sub_options.has_sub_options = false
      expect{option_with_sub_options.save}.to change{option_with_sub_options.sub_options.length}.by -sub_options_length
    end
  end

  describe "ordering" do
    let (:options) {create_list(:option, 5, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id)}

    it "should be ordered from 1 to 5" do
      expect(options.length).to eq(5)
      options.each_with_index do |option, index|
        expect(option.option_order).to eq(index + 1)
      end
    end

    it "should change the ordering when change_order is called" do
      option_to_change = options.first
      option_to_change.change_order(5)
      expect(option_to_change.option_order).to eq(5)
      options.each do |o|
        o.reload
        expect(o.option_order).to be <= 5
      end
      expect(options.map(&:option_order).uniq.length).to eq(options.length)
    end

    it "should correct the ordering when an option is deleted" do
      option_to_delete = options.delete_at(2)
      option_to_delete.destroy
      options.each do |o|
        o.reload
        expect(o.option_order).to be <= 4
      end
      expect(options.map(&:option_order).uniq.length).to eq(options.length)
    end
  end
  
  describe "associations" do
    let (:option) { create(:option, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id) }
    let (:option_with_sub_options) { create(:option_with_sub_options, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id) }

    it "destroys option properties on destroy" do
      p = create(:property, decision_aid: decision_aid)
      op = create(:option_property, decision_aid: decision_aid, property: p, option: option)
      expect(option.option_properties).to include(op)
      expect{option.destroy}.to change{OptionProperty.count}.by(-1)
      expect(OptionProperty.exists?(op.id)).to be false
    end

    it "destroys sub_options on destroy" do
      so = create(:option, option_id: option_with_sub_options.id, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id)
      expect(option_with_sub_options.sub_options).to include(so)
      option_with_sub_options.destroy
      expect(Option.exists?(so.id)).to be false
    end

    it "nullifies decision aid user selected option on destroy" do
      u = create(:decision_aid_user, decision_aid: decision_aid, selected_option_id: option.id)
      expect(u.selected_option_id).to eq(option.id)
      option.destroy
      expect(u.reload.selected_option_id).to be_nil
    end

    it "destroys decision aid user option properties on destroy" do
      u = create(:decision_aid_user, decision_aid: decision_aid, selected_option_id: option.id)
      property = create(:property, decision_aid: decision_aid)
      option_property = create(:option_property, property_id: property.id, option_id: option.id, decision_aid_id: decision_aid.id)
      up = create(:decision_aid_user_property, weight: 50, decision_aid_user_id: u.id, property_id: property.id)
      uop = create(:decision_aid_user_option_property, value: 5, option_id: option.id, property_id: property.id, option_property_id: option_property.id, decision_aid_user_id: u.id)
      expect(option.decision_aid_user_option_properties).to include(uop)
      expect{option.destroy}.to change{DecisionAidUserOptionProperty.count}.by(-1)
      expect(DecisionAidUserOptionProperty.exists?(uop.id)).to be false
    end
  end

  describe "injectable" do 
    it_should_behave_like "injectable", :option, :option
  end

  describe "has_attached_items" do
    it_should_behave_like "has_attached_items", :option, :option
  end

  describe "user_stamps" do
    it_behaves_like "user_stamps" do
      let (:item) { create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id) }
    end
  end

  describe "methods" do
    let (:option) { create(:option, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id) }
    let (:option_with_sub_options) { create(:option_with_sub_options, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id) }

    describe ".clone_option" do
      it "should clone a valid option" do
        option.reload
        expect(option.valid?).to be true
        expect{option.clone_option(decision_aid)}
          .to change{decision_aid.reload.options_count}.by(1)
      end

      it "should set the cloned option's order to the initial option input plus one" do
        r = option.clone_option(decision_aid)
        expect(r).to have_key :option
        expect(r[:option]).to respond_to "option_order"
        expect(r[:option].option_order).to be(option.option_order + 1)
      end

      it "should fail to clone an invalid option" do
        option.decision_aid_id = nil
        expect(option.valid?).to be false
        r = option.clone_option(decision_aid)
        expect(r).to have_key(:errors)
      end

      it "should clone an option with sub_options" do
        r = option_with_sub_options.clone_option(decision_aid)
        expect(r[:option].sub_options.length).to eq(option_with_sub_options.sub_options.length)
        option_with_sub_options.sub_options.each_with_index do |so, index|
          expect(so.option_order).to eq(r[:option].sub_options[index].option_order)
        end
      end
    end
  end
end
