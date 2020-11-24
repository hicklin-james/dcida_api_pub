# == Schema Information
#
# Table name: static_pages
#
#  id                  :integer          not null, primary key
#  page_text           :text
#  page_text_published :text
#  page_title          :text
#  static_page_order   :integer          not null
#  decision_aid_id     :integer
#  page_slug           :text
#  created_by_user_id  :integer
#  updated_by_user_id  :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'rails_helper'

RSpec.describe StaticPage, type: :model do
  describe "validations" do
    let (:decision_aid) {create(:basic_decision_aid)}
    let (:other_decision_aid) {create(:basic_decision_aid)}

    it "should save when all required attributes are present" do
      sp = build(:static_page, decision_aid_id: decision_aid.id)
      expect(sp.save).to be true
    end

    it "should fail to save when decision aid is missing" do
      sp = build(:static_page)
      expect(sp.save).to be false
      expect(sp.errors.messages).to have_key :decision_aid_id
    end

    it "should fail to save when page_text is missing" do
      sp = build(:static_page, decision_aid_id: decision_aid.id, page_text: nil)
      expect(sp.save).to be false
      expect(sp.errors.messages).to have_key :page_text
    end

    it "should fail to save when page_slug is missing" do
      sp = build(:static_page, decision_aid_id: decision_aid.id, page_slug: nil)
      expect(sp.save).to be false
      expect(sp.errors.messages).to have_key :page_slug
    end

    it "should fail to save when page_title is missing" do
      sp = build(:static_page, decision_aid_id: decision_aid.id, page_title: nil)
      expect(sp.save).to be false
      expect(sp.errors.messages).to have_key :page_title
    end

    it "should not allow multiple static_pages within a decision aid have the same page_slug" do
      sp1 = build(:static_page, decision_aid_id: decision_aid.id, page_slug: "myslug")
      sp2 = build(:static_page, decision_aid_id: decision_aid.id, page_slug: "myslug")

      expect(sp1.save).to be true
      expect(sp2.save).to be false
      expect(sp2.errors.messages).to have_key :page_slug
    end

    it "should allow multiple static_pages to have the same page_slug if they are in different decision aids" do
      sp1 = build(:static_page, decision_aid_id: decision_aid.id, page_slug: "myslug")
      sp2 = build(:static_page, decision_aid_id: other_decision_aid.id, page_slug: "myslug")

      expect(sp1.save).to be true
      expect(sp2.save).to be true
    end
  end

  describe "injectable" do
    it_should_behave_like "injectable", :static_page, :static_page
  end

  describe "has_attached_items" do
    it_should_behave_like "has_attached_items", :static_page, :static_page
  end
end
