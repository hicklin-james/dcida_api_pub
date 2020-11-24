# == Schema Information
#
# Table name: option_properties
#
#  id                    :integer          not null, primary key
#  information           :text
#  short_label           :text
#  option_id             :integer          not null
#  property_id           :integer          not null
#  decision_aid_id       :integer          not null
#  created_by_user_id    :integer
#  updated_by_user_id    :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  information_published :text
#  ranking               :text
#  ranking_type          :integer
#  short_label_published :text
#  button_label          :string
#

require "rails_helper"

RSpec.describe OptionProperty, :type => :model do
  let (:decision_aid) { create(:basic_decision_aid) }
  let (:option) { create(:option, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id) }
  let (:property) { create(:property, decision_aid: decision_aid) }
  let (:option_rankings_decision_aid) { create(:basic_decision_aid, decision_aid_type: "treatment_rankings") }
  let (:option_2) { create(:option, decision_aid: option_rankings_decision_aid, sub_decision_id: option_rankings_decision_aid.sub_decisions.first.id) }
  let (:property_2) { create(:property, decision_aid: option_rankings_decision_aid) }

  describe "validations" do
    it "doesn't save if the option is missing" do
      op = build(:option_property, decision_aid: decision_aid, property: property)
      expect(op.save).to be false
      expect(op.errors.messages).to have_key :option_id
    end

    it "doesn't save if the property is missing" do
      op = build(:option_property, decision_aid: decision_aid, option: option)
      expect(op.save).to be false
      expect(op.errors.messages).to have_key :property_id
    end

    it "doesn't save if the decision aid is missing" do
      op = build(:option_property, property: property, option: option)
      expect(op.save).to be false
      expect(op.errors.messages).to have_key :decision_aid_id
    end

    it "fails to save if the short_label is missing" do
      op = build(:option_property, property: property, option: option, decision_aid: decision_aid, short_label: nil)
      expect(op.save).to be false
      expect(op.errors.messages).to have_key :short_label
    end

    # it "fails to save if the decision aid is an option_rankings decision aid and the ranking is missing" do
    #   op = build(:option_property, property: property_2, option: option_2, decision_aid: option_rankings_decision_aid, ranking_type: OptionProperty.ranking_types[:integer])
    #   expect(op.save).to be false
    #   expect(op.errors.messages).to have_key :ranking
    # end

    # it "fails to save if the ranking value is above 10" do
    #   op = build(:option_property, property: property_2, option: option_2, decision_aid: option_rankings_decision_aid, ranking: 11, ranking_type: OptionProperty.ranking_types[:integer])
    #   expect(op.save).to be false
    #   expect(op.errors.messages).to have_key :ranking
    # end

    # it "fails to save if the ranking value is below 0" do
    #   op = build(:option_property, property: property_2, option: option_2, decision_aid: option_rankings_decision_aid, ranking: -1, ranking_type: OptionProperty.ranking_types[:integer])
    #   expect(op.save).to be false
    #   expect(op.errors.messages).to have_key :ranking
    # end

    it "fails to save if the ranking value is an invalid format" do
      op = build(:option_property, property: property_2, option: option_2, decision_aid: option_rankings_decision_aid, ranking: "[question bad format]", ranking_type: OptionProperty.ranking_types[:question_response_value])
      expect(op.save).to be false
      expect(op.errors.messages).to have_key :ranking
    end

    it "saves if there is a decision aid, option, and property when the decision aid is standard" do
      op = build(:option_property, property: property, option: option, decision_aid: decision_aid)
      expect(op.save).to be true
    end

    it "saves if there is a decision aid, option, and property when the decision aid is option_rankings and ranking type is integer" do
      op = build(:option_property, property: property_2, option: option_2, decision_aid: option_rankings_decision_aid, ranking: 5, ranking_type: OptionProperty.ranking_types[:integer])
      expect(op.save).to be true
    end

    it "saves if there is a decision aid, option, and property when the decision aid is option_rankings and ranking type is question_response_value" do
      op = build(:option_property, property: property_2, option: option_2, decision_aid: option_rankings_decision_aid, ranking: "[question id=\"123\"]", ranking_type: OptionProperty.ranking_types[:question_response_value])
      expect(op.save).to be true
    end

  end

  describe "callbacks" do    
    let (:option_property) { create(:option_property, property: property, option: option, decision_aid: decision_aid) }
    
    it "publishes accordion values after saving" do
      expect(option_property.information_published).to eq(option_property.information)
    end
  end

  describe "injectable" do
    it_should_behave_like "injectable", :option_property, :option_property
  end

  describe "has_attached_items" do
    it_should_behave_like "has_attached_items", :option_property, :option_property
  end

  describe "user_stamps" do
    it_behaves_like "user_stamps" do
      let (:item) { create(:option_property, property: property, option: option, decision_aid: decision_aid) }
    end
  end

  describe "methods" do
    describe ".generate_ranking_value" do
      it "should return a number if the ranking_type is integer" do
        op = create(:option_property, property: property, option: option, decision_aid: decision_aid, ranking: 5, ranking_type: OptionProperty.ranking_types[:integer])
        dau = create(:decision_aid_user, decision_aid: decision_aid)
        expect(op.generate_ranking_value(dau)).to eq 5
      end

      it "should return a response numeric value if the ranking_type is question_response_value" do
        response_attrs = FactoryGirl.attributes_for(:question_response, numeric_value: 4.32, decision_aid: decision_aid, question_response_order: 1)
        q = create(:demo_radio_question, question_responses_attributes: [response_attrs], decision_aid: decision_aid)
        op = create(:option_property, property: property, option: option, decision_aid: decision_aid, ranking: "[question id=\"#{q.id}\"]", ranking_type: OptionProperty.ranking_types[:question_response_value])
        dau = create(:decision_aid_user, decision_aid: decision_aid)
        daur = create(:decision_aid_user_response, decision_aid_user: dau, question_id: q.id, question_response_id: q.question_responses.first.id)
        expect(op.generate_ranking_value(dau.reload)).to be 4.32
      end

      it "should return nil if there is no user response associated with the matched question id and the ranking_type is question_response_value" do
        op = create(:option_property, property: property, option: option, decision_aid: decision_aid, ranking: "[question id=\"0\"]", ranking_type: OptionProperty.ranking_types[:question_response_value])
        dau = create(:decision_aid_user, decision_aid: decision_aid)
        expect(op.generate_ranking_value(dau.reload)).to be nil
      end

      it "should return nil if there is a user response but the question has no question response and the ranking_type is question_response_value" do
        q = create(:demo_text_question, decision_aid: decision_aid)
        op = create(:option_property, property: property, option: option, decision_aid: decision_aid, ranking: "[question id=\"0\"]", ranking_type: OptionProperty.ranking_types[:question_response_value])
        dau = create(:decision_aid_user, decision_aid: decision_aid)
        daur = create(:decision_aid_user_response, decision_aid_user: dau, question_id: q.id)
        expect(op.generate_ranking_value(dau.reload)).to be nil
      end
    end

    describe "::bulk_update_option_properties" do

      before do
        @update_hash = {}
        @ops = [create(:option_property, property: property, option: option, decision_aid: decision_aid),
               create(:option_property, property: property_2, option: option_2, decision_aid: decision_aid),
               create(:option_property, property: property, option: option_2, decision_aid: decision_aid),
               create(:option_property, property: property_2, option: option, decision_aid: decision_aid)]
        @new_short_label = "cool new short label"

        @ops.each do |op|
          expect(op.short_label).not_to eq(@new_short_label)
          @update_hash[op.id.to_s] = {:short_label => @new_short_label}
        end
      end

      it "should update option properties" do
        updated_ops = OptionProperty::bulk_update_option_properties(@update_hash, @ops)
        expect(updated_ops.length).to be > 0
        updated_ops.each do |op|
          expect(op.short_label).to eq(@new_short_label)
        end
      end

      it "should raise an exception if a fake id exists in params" do
        @update_hash[0] = {:short_label => @new_short_label}
        expect{OptionProperty::bulk_update_option_properties(@update_hash, @ops)}
          .to raise_error(Exceptions::InvalidParams)
      end
    end

    describe "::bulk_create_option_properties" do
      it "should create new option properties" do
        create_params = [FactoryGirl.attributes_for(:option_property, property_id: property.id, option_id: option.id, decision_aid_id: decision_aid.id),
               FactoryGirl.attributes_for(:option_property, property_id: property_2.id, option_id: option_2.id, decision_aid_id: decision_aid.id),
               FactoryGirl.attributes_for(:option_property, property_id: property.id, option_id: option_2.id, decision_aid_id: decision_aid.id),
               FactoryGirl.attributes_for(:option_property, property_id: property_2.id, option_id: option.id, decision_aid_id: decision_aid.id)]
        expect{OptionProperty::bulk_create_option_properties(create_params, decision_aid.id)}
          .to change{decision_aid.reload.option_properties_count}.by create_params.length
      end
    end
  end
end
