require 'rails_helper'

# isolation tests for has_attached_items
RSpec.describe Shared::HasAttachedItems, :type => :model do
  let (:user) { create(:user) }
  let (:decision_aid) { create(:basic_decision_aid) }
  let (:accordion) { create(:accordion, user_id: user.id, decision_aid_id: decision_aid.id) }
  let (:graphic) { create(:horizontal_bar_chart_graphic, decision_aid_id: decision_aid.id) }
  
  describe "updating existing accordions" do
    it "updates all objects that use that accordion" do
       #decision_aid = create(:basic_decision_aid, description: "[accordion id=\"#{accordion.id}\"]")
       decision_aid.description = "[accordion id=\"#{accordion.id}\"] [graphic id=\"#{graphic.acting_as.id}\"]"
       decision_aid.save
       option = create(:option, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id, description: "[accordion id=\"#{accordion.id}\"]")
       ac = accordion.accordion_contents.first
       old_content = ac.content
       expect(/#{old_content}/).to match(decision_aid.description_published)
       expect(/#{old_content}/).to match(option.description_published)
       new_content = "lol"
       ac.content = new_content
       ac.save
       accordion.save
       expect(/#{old_content}/).not_to match(decision_aid.reload.description_published)
       expect(/#{old_content}/).not_to match(option.reload.description_published)
       expect(/#{new_content}/).to match(decision_aid.reload.description_published)
       expect(/#{new_content}/).to match(option.reload.description_published)
    end

    it "updates all instances of the accordion within that object" do
      #decision_aid = create(:basic_decision_aid, description: "[accordion id=\"#{accordion.id}\"]", about_information: "[accordion id=\"#{accordion.id}\"]")
      decision_aid.update_attributes(description: "[accordion id=\"#{accordion.id}\"] [graphic id=\"#{graphic.acting_as.id}\"]",
        about_information: "[accordion id=\"#{accordion.id}\"] [graphic id=\"#{graphic.acting_as.id}\"]")
      ac = accordion.accordion_contents.first
      old_content = ac.content
      expect(/#{old_content}/).to match(decision_aid.description_published)
      expect(/#{old_content}/).to match(decision_aid.about_information_published)
      new_content = "lol"
      ac.content = new_content
      ac.save
      accordion.save
      expect(/#{old_content}/).not_to match(decision_aid.reload.description_published)
      expect(/#{old_content}/).not_to match(decision_aid.reload.about_information_published)
      expect(/#{new_content}/).to match(decision_aid.reload.description_published)
      expect(/#{new_content}/).to match(decision_aid.reload.about_information_published)
    end

    it "removes reference if the object no longer exists" do
      AccordionObjectReference.create(object_type: "Option", object_id: 0, accordion_id: accordion.id) # create reference with fake id
      expect(AccordionObjectReference.count).to eq 1
      expect{accordion.save}
        .to change{AccordionObjectReference.count}.by -1
    end
  end

  describe "updating existing graphics" do
    it "updates all objects that use that graphic" do
       #decision_aid = create(:basic_decision_aid, description: "[accordion id=\"#{accordion.id}\"]")
       decision_aid.description = "[accordion id=\"#{accordion.id}\"] [graphic id=\"#{graphic.acting_as.id}\"]"
       decision_aid.save
       option = create(:option, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id, description: "[graphic id=\"#{graphic.acting_as.id}\"]")
       datum = graphic.graphic_data.first
       new_content = "564"
       datum.value = new_content
       datum.save
       graphic.save
       expect(/#{new_content}/).to match(decision_aid.reload.description_published)
       expect(/#{new_content}/).to match(option.reload.description_published)
    end

    it "updates all instances of the graphic within that object" do
      decision_aid.update_attributes(description: "[accordion id=\"#{accordion.id}\"] [graphic id=\"#{graphic.acting_as.id}\"]",
        about_information: "[accordion id=\"#{accordion.id}\"] [graphic id=\"#{graphic.acting_as.id}\"]")
      datum = graphic.graphic_data.first
      new_content = "564"
      datum.value = new_content
      datum.save
      graphic.save
      expect(/#{new_content}/).to match(decision_aid.reload.description_published)
      expect(/#{new_content}/).to match(decision_aid.reload.about_information_published)
    end

    it "removes reference if the object no longer exists" do
      GraphicObjectReference.create(object_type: "Option", object_id: 0, graphic_id: graphic.acting_as.id) # create reference with fake id
      expect(GraphicObjectReference.count).to eq 1
      expect{graphic.save}
        .to change{GraphicObjectReference.count}.by -1
    end
  end
end