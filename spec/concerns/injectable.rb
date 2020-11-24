require 'rails_helper'

shared_examples_for "injectable" do |class_name, factory_name|
  let (:decision_aid) {create(:basic_decision_aid)}
  let (:option) {create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id)}
  let (:property) {create(:property, decision_aid_id: decision_aid.id)}
  let (:property_level) { create(:property_level, decision_aid_id: decision_aid.id, level_id: 1, property_id: property.id) }
  let (:model) { described_class } # the class that includes the concern
  let (:dau) { create(:decision_aid_user, decision_aid_id: decision_aid.id) }
  let (:summary_panel) { create(:summary_panel, decision_aid_id: decision_aid.id, panel_type: 0, summary_panel_order: 1) }
  let (:intro_page) { create(:intro_page, decision_aid_id: decision_aid.id)}
  #let (:item) { create(factory_name, decision_aid_id: decision_aid.id, option_id: option.id, property_id: property.id) }

  before(:each) do
    params = {decision_aid_id: decision_aid.id, option_id: option.id, property_id: property.id, 
              level_id: 1, sub_decision_id: decision_aid.sub_decisions.first.id, panel_type: 0, 
              summary_panel_order: 1}
    instance = model.new
    p = params.reject{|k,v| !instance.attributes.keys.member?(k.to_s) }
    @item = create(factory_name, p)
  end

  describe "text question" do
    let!(:q) { create(:demo_text_question, decision_aid_id: decision_aid.id) }
    let!(:r) { create(:decision_aid_user_response, question_id: q.id, response_value: "injected string", decision_aid_user_id: dau.id) }

    fields = (class_name.to_s.camelize.constantize)::INJECTABLE_ATTRIBUTES
    fields.each do |m|
      it "injects text correctly for #{m}" do
        injectable_method = "injected_#{m}"
        item_attr = m.to_s.gsub("injected_", "")
        item_attr = item_attr.gsub("_published", "").to_sym
        @item.update_attribute(item_attr, "abc [question id=\"#{q.id}\"] def")
        expect(@item.send(injectable_method, dau)).to include("injected string")
      end
    end
  end

  describe "number question" do
    let!(:q) { create(:demo_number_question, decision_aid_id: decision_aid.id) }
    let!(:r) { create(:decision_aid_user_response, question_id: q.id, number_response_value: 54321, decision_aid_user_id: dau.id) }

    fields = (class_name.to_s.camelize.constantize)::INJECTABLE_ATTRIBUTES
    fields.each do |m|
      it "injects number correctly for #{m}" do
        injectable_method = "injected_#{m}"
        item_attr = m.to_s.gsub("injected_", "")
        item_attr = item_attr.gsub("_published", "").to_sym
        @item.update_attribute(item_attr, "abc [question id=\"#{q.id}\"] def")
        expect(@item.send(injectable_method, dau)).to include("54321")
      end
    end
  end

  describe "radio question" do
    let!(:q) { create(:demo_radio_question, decision_aid_id: decision_aid.id) }
    let!(:r) { create(:decision_aid_user_response, question_id: q.id, question_response_id: q.question_responses.first.id, decision_aid_user_id: dau.id) }

    fields = (class_name.to_s.camelize.constantize)::INJECTABLE_ATTRIBUTES

    fields.each do |m|
      it "injects question response value correctly for #{m}" do
        injectable_method = "injected_#{m}"
        item_attr = m.to_s.gsub("injected_", "")
        item_attr = item_attr.gsub("_published", "").to_sym
        @item.update_attribute(item_attr, "abc [question id=\"#{q.id}\"] def")
        expect(@item.send(injectable_method, dau)).to include(q.question_responses.first.question_response_value)
      end
    end
  end

  describe "lookup table question" do
    let (:q1) { create(:demo_radio_question, decision_aid: decision_aid) }
    let (:q2) { create(:demo_radio_question, decision_aid: decision_aid) }
    let!(:q) { create(:demo_lookup_table_question, decision_aid_id: decision_aid.id, lookup_table: create_lookup_json, lookup_table_dimensions: [q1.id, q2.id]) }
    let!(:r) { create(:decision_aid_user_response, question_id: q.id, lookup_table_value: 5.5, decision_aid_user_id: dau.id) }

    def create_lookup_json
      json = Hash.new
      index = 0
      q1.question_responses.each do |qrq1|
        json[qrq1.id] = Hash.new
        q2.question_responses.each do |qrq2|
          json[qrq1.id][qrq2.id] = index
          index += 1
        end
      end
      json
    end

    fields = (class_name.to_s.camelize.constantize)::INJECTABLE_ATTRIBUTES
    fields.each do |m|
      injectable_method = "injected_#{m}"
      it "injects question response value correctly for #{m}" do
        r.update_attribute(:lookup_table_value, 5)
        item_attr = m.to_s.gsub("injected_", "")
        item_attr = item_attr.gsub("_published", "").to_sym
        @item.update_attribute(item_attr, "abc [question id=\"#{q.id}\"] def")
        expect(@item.send(injectable_method, dau)).to include("5")
      end
    end
  end

  describe "grid question" do
    let!(:q) { create(:demo_grid_question, decision_aid_id: decision_aid.id) }
    let!(:r) { create(:decision_aid_user_response, question_id: q.id, number_response_value: 54321, decision_aid_user_id: dau.id) }
    
    fields = (class_name.to_s.camelize.constantize)::INJECTABLE_ATTRIBUTES
    fields.each do |m|
      it "does nothing with #{m} if the question is a grid question" do
        injectable_method = "injected_#{m}"
        published_item_attr = m.to_s.gsub("injected_", "")
        item_attr = published_item_attr.gsub("_published", "").to_sym
        @item.update_attribute(item_attr, "abc [question id=\"#{q.id}\"] def")
        expect(@item.send(injectable_method, dau)).to eq "abc  def"
      end
    end
  end

  describe "no response" do

    fields = (class_name.to_s.camelize.constantize)::INJECTABLE_ATTRIBUTES
    fields.each do |m|
      it "does nothing with #{m} if there is no response to the question" do
        injectable_method = "injected_#{m}"
        published_item_attr = m.to_s.gsub("injected_", "")
        item_attr = published_item_attr.gsub("_published", "").to_sym
        @item.update_attribute(item_attr, "abc [question id=\"010101\"] def")
        expect(@item.send(injectable_method, dau)).to eq "abc  def"
      end
    end
  end
end