require 'rails_helper'
# shared tests for has_attached_@items
shared_examples_for "has_attached_items" do |class_name, factory_name|

  let (:decision_aid) {create(:basic_decision_aid)}
  let (:option) {create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id)}
  let (:property) {create(:property, decision_aid_id: decision_aid.id)}
  let (:property_level) { create(:property_level, decision_aid_id: decision_aid.id, level_id: 1, property_id: property.id) }
  let (:question) {  create(:demo_text_question, decision_aid: decision_aid) }
  let (:static_page) { create(:static_page, decision_aid: decision_aid) }
  #let (:item) { create(factory_name, generate_attributes) }
  let (:model) { described_class }
  let (:user) { create(:user) }
  let (:accordion) { create(:accordion, user_id: user.id, decision_aid_id: decision_aid.id) }
  let (:graphic) { create(:horizontal_bar_chart_graphic, decision_aid_id: decision_aid.id) }
  let (:intro_page) {create:intro_page, decision_aid_id: decision_aid.id}

  before(:each) do
    params = {decision_aid_id: decision_aid.id, option_id: option.id, property_id: property.id, level_id: 1, sub_decision_id: decision_aid.sub_decisions.first.id}
    instance = model.new
    p = params.reject{|k,v| !instance.attributes.keys.member?(k.to_s) }
    @item = create(factory_name, p)
  end

  describe "accordion object references" do

    fields = (class_name.to_s.camelize.constantize)::HAS_ATTACHED_ITEMS_ATTRIBUTES
    fields.each do |f|
      describe "attribute #{f}" do
        it "adds a new reference when an accordion is added to an object" do
          @item.send("#{f}=", "[accordion id=\"#{accordion.id}\"]")
          expect{@item.save}.to change{AccordionObjectReference.count}.by(1)
        end

        it "deletes a reference when an object is destroyed" do
          @item.send("#{f}=", "[accordion id=\"#{accordion.id}\"]")
          @item.save
          expect{@item.destroy}.to change{AccordionObjectReference.count}.by(-1)
        end

        it "deletes a reference when an object removes an accordion" do
          @item.send("#{f}=", "[accordion id=\"#{accordion.id}\"]")
          @item.save
          expect{@item.update_attribute(f, "no more accordion")}.to change{AccordionObjectReference.count}.by(-1)
        end

        it "doesn't delete a reference if the object is not saved properly" do
          @item.send("#{f}=", "[accordion id=\"#{accordion.id}\"]")
          @item.save
          @item.send("#{f}=", "no more accordion")
          # force save to fail
          @item.created_at = nil
          old_count = AccordionObjectReference.count
          expect{@item.save}.to raise_error(ActiveRecord::StatementInvalid)
          expect(AccordionObjectReference.count).to eq old_count
        end

        it "doesn't add a reference if the accordion is not a real accordion" do
          @item.send("#{f}=", "[accordion id=\"0\"]")
          expect{@item.save}.not_to change{AccordionObjectReference.count}
        end

        it "adds multiple references for multiple accordions in the same attribute" do
          a_2 = create(:accordion, decision_aid_id: decision_aid.id, user_id: user.id)
          @item.send("#{f}=", "[accordion id=\"#{accordion.id}\"] [accordion id=\"#{a_2.id}\"]")
          expect{@item.save}.to change{AccordionObjectReference.count}.by(2)
        end

        it "only deletes one reference if there are multiple accordions in the same attribute and one is removed" do
          a_2 = create(:accordion, decision_aid_id: decision_aid.id, user_id: user.id)
          @item.send("#{f}=", "[accordion id=\"#{accordion.id}\"] [accordion id=\"#{a_2.id}\"]")
          @item.save
          @item.send("#{f}=", "[accordion id=\"#{accordion.id}\"]")
          ref = AccordionObjectReference.where(accordion_id: a_2.id, object_id: @item.id).first
          expect(AccordionObjectReference.all).to include(ref)
          expect{@item.save}.to change{AccordionObjectReference.count}.by(-1)
          expect(AccordionObjectReference.all).not_to include(ref)
        end
      end
    end

    describe "multiple attributes" do
      fields = (class_name.to_s.camelize.constantize)::HAS_ATTACHED_ITEMS_ATTRIBUTES

      if fields.length >= 2
        it "only adds one reference despite multiple fields having that accordion" do
          f1 = fields.first
          f2 = fields.second
          @item.send("#{f1}=", "[accordion id=\"#{accordion.id}\"]")
          @item.send("#{f2}=", "[accordion id=\"#{accordion.id}\"]")
          expect{@item.save}.to change{AccordionObjectReference.count}.by(1)
        end

        it "only removes the reference when all fields no longer have a reference to that accordion" do
          f1 = fields.first
          f2 = fields.second
          @item.send("#{f1}=", "[accordion id=\"#{accordion.id}\"]")
          @item.send("#{f2}=", "[accordion id=\"#{accordion.id}\"]")
          expect{@item.save}.to change{AccordionObjectReference.count}.by(1)
          @item.send("#{f1}=", "no more accordion")
          expect{@item.save}.not_to change{AccordionObjectReference.count}
          @item.send("#{f2}=", "no more accordion")
          expect{@item.save}.to change{AccordionObjectReference.count}.by(-1)
        end

        it "adds multiple references for multiple accordions in different attributes" do
          a_2 = create(:accordion, decision_aid_id: decision_aid.id, user_id: user.id)
          f1 = fields.first
          f2 = fields.second
          @item.send("#{f1}=", "[accordion id=\"#{accordion.id}\"]")
          @item.send("#{f2}=", "[accordion id=\"#{a_2.id}\"]")
          expect{@item.save}.to change{AccordionObjectReference.count}.by(2)
        end

        it "only deletes one reference if there are multiple accordions on multiple attributes" do
         a_2 = create(:accordion, decision_aid_id: decision_aid.id, user_id: user.id)
          f1 = fields.first
          f2 = fields.second
          @item.send("#{f1}=", "[accordion id=\"#{accordion.id}\"]")
          @item.send("#{f2}=", "[accordion id=\"#{a_2.id}\"]")
          @item.save
          @item.send("#{f2}=", "no more accordion")
          ref = AccordionObjectReference.where(accordion_id: a_2.id, object_id: @item.id).first
          expect(AccordionObjectReference.all).to include(ref)
          expect{@item.save}.to change{AccordionObjectReference.count}.by(-1)
          expect(AccordionObjectReference.all).not_to include(ref)
        end
      end
    end
  end

  describe "graphic object references" do
    fields = (class_name.to_s.camelize.constantize)::HAS_ATTACHED_ITEMS_ATTRIBUTES
    fields.each do |f|
      describe "attribute #{f}" do
        it "adds a new reference when a graphic is added to an object" do
          @item.send("#{f}=", "[graphic id=\"#{graphic.acting_as.id}\"]")
          expect{@item.save}.to change{GraphicObjectReference.count}.by(1)
        end

        it "deletes a reference when an object is destroyed" do
          @item.send("#{f}=", "[graphic id=\"#{graphic.acting_as.id}\"]")
          @item.save
          expect{@item.destroy}.to change{GraphicObjectReference.count}.by(-1)
        end

        it "deletes a reference when an object removes a graphic" do
          @item.send("#{f}=", "[graphic id=\"#{graphic.acting_as.id}\"]")
          @item.save
          expect{@item.update_attribute(f, "no more graphic")}.to change{GraphicObjectReference.count}.by(-1)
        end

        it "doesn't delete a reference if the object is not saved properly" do
          @item.send("#{f}=", "[graphic id=\"#{graphic.acting_as.id}\"]")
          @item.save
          @item.send("#{f}=", "no more graphic")
          # force save to fail
          @item.created_at = nil
          old_count = GraphicObjectReference.count
          expect{@item.save}.to raise_error(ActiveRecord::StatementInvalid)
          expect(GraphicObjectReference.count).to eq old_count
        end

        it "doesn't add a reference if the graphic is not a real graphic" do
          @item.send("#{f}=", "[graphic id=\"0\"]")
          expect{@item.save}.not_to change{GraphicObjectReference.count}
        end

        it "adds multiple references for multiple graphics in the same attribute" do
          g_2 = create(:horizontal_bar_chart_graphic, decision_aid_id: decision_aid.id)
          @item.send("#{f}=", "[graphic id=\"#{graphic.acting_as.id}\"] [graphic id=\"#{g_2.acting_as.id}\"]")
          expect{@item.save}.to change{GraphicObjectReference.count}.by(2)
        end

        it "only deletes one reference if there are multiple graphics in the same attribute and one is removed" do
          g_2 = create(:horizontal_bar_chart_graphic, decision_aid_id: decision_aid.id)
          @item.send("#{f}=", "[graphic id=\"#{graphic.acting_as.id}\"] [graphic id=\"#{g_2.acting_as.id}\"]")
          @item.save
          @item.send("#{f}=", "[graphic id=\"#{graphic.acting_as.id}\"]")
          ref = GraphicObjectReference.where(graphic_id: g_2.acting_as.id, object_id: @item.id).first
          expect(GraphicObjectReference.all).to include(ref)
          expect{@item.save}.to change{GraphicObjectReference.count}.by(-1)
          expect(GraphicObjectReference.all).not_to include(ref)
        end
      end
    end

    describe "multiple attributes" do
      fields = (class_name.to_s.camelize.constantize)::HAS_ATTACHED_ITEMS_ATTRIBUTES

      if fields.length >= 2
        it "only adds one reference despite multiple fields having that graphic" do
          f1 = fields.first
          f2 = fields.second
          @item.send("#{f1}=", "[graphic id=\"#{graphic.acting_as.id}\"]")
          @item.send("#{f2}=", "[graphic id=\"#{graphic.acting_as.id}\"]")
          expect{@item.save}.to change{GraphicObjectReference.count}.by(1)
        end

        it "only removes the reference when all fields no longer have a reference to that graphic" do
          f1 = fields.first
          f2 = fields.second
          @item.send("#{f1}=", "[graphic id=\"#{graphic.acting_as.id}\"]")
          @item.send("#{f2}=", "[graphic id=\"#{graphic.acting_as.id}\"]")
          expect{@item.save}.to change{GraphicObjectReference.count}.by(1)
          @item.send("#{f1}=", "no more graphic")
          expect{@item.save}.not_to change{GraphicObjectReference.count}
          @item.send("#{f2}=", "no more graphic")
          expect{@item.save}.to change{GraphicObjectReference.count}.by(-1)
        end

        it "adds multiple references for multiple graphics in different attributes" do
          g_2 = create(:horizontal_bar_chart_graphic, decision_aid_id: decision_aid.id)
          f1 = fields.first
          f2 = fields.second
          @item.send("#{f1}=", "[graphic id=\"#{graphic.acting_as.id}\"]")
          @item.send("#{f2}=", "[graphic id=\"#{g_2.acting_as.id}\"]")
          expect{@item.save}.to change{GraphicObjectReference.count}.by(2)
        end

        it "only deletes one reference if there are multiple graphics on multiple attributes" do
          g_2 = create(:horizontal_bar_chart_graphic, decision_aid_id: decision_aid.id)
          f1 = fields.first
          f2 = fields.second
          @item.send("#{f1}=", "[graphic id=\"#{graphic.acting_as.id}\"]")
          @item.send("#{f2}=", "[graphic id=\"#{g_2.acting_as.id}\"]")
          @item.save
          @item.send("#{f2}=", "no more graphic")
          ref = GraphicObjectReference.where(graphic_id: g_2.acting_as.id, object_id: @item.id).first
          expect(GraphicObjectReference.all).to include(ref)
          expect{@item.save}.to change{GraphicObjectReference.count}.by(-1)
          expect(GraphicObjectReference.all).not_to include(ref)
        end
      end
    end
  end
end