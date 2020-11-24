# == Schema Information
#
# Table name: intro_pages
#
#  id                    :integer          not null, primary key
#  description           :text
#  description_published :text
#  decision_aid_id       :integer
#  intro_page_order      :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  created_by_user_id    :integer
#  updated_by_user_id    :integer
#

require 'rails_helper'

RSpec.describe IntroPage, type: :model do
  describe "validations" do	
  	let (:decision_aid) { create(:basic_decision_aid) }

    it "should fail to save if decision_aid_id is missing" do
      intro_page = build(:intro_page)
      expect(intro_page.save).to be false
      expect(intro_page.errors.messages).to have_key :decision_aid_id
    end

    it "should fail to save if description is missing" do 
      ip = build(:intro_page, description: nil, decision_aid_id: decision_aid.id)
      expect(ip.save).to be false
      expect(ip.errors.messages).to have_key :description
    end 
  end

  describe "ordering" do
    let (:decision_aid) { create(:basic_decision_aid) } # this creates an initial intro page
    let! (:intro_pages) {create_list(:intro_page, 5, decision_aid: decision_aid)} # this creates 5 more intro pages

    it "should be ordered from 1 to 5" do
      expect(decision_aid.intro_pages.length).to eq(6)
      decision_aid.intro_pages.each_with_index do |intro_page, index|
        expect(intro_page.intro_page_order).to eq(index + 1)
      end
    end

    it "should change the ordering when change_order is called" do
      intro_page_to_change = decision_aid.intro_pages.first
      intro_page_to_change.change_order(5)
      expect(intro_page_to_change.intro_page_order).to eq(5)
      orders = []
      decision_aid.intro_pages.each do |p|
        p.reload
        expect(p.intro_page_order).to be <= 6
        expect(p.intro_page_order).to be > 0
        expect(orders).not_to include(p.intro_page_order)
        orders.push p.intro_page_order
      end
      expect(decision_aid.intro_pages.map(&:intro_page_order).uniq.length).to eq(decision_aid.intro_pages.length)
    end

    it "should correct the ordering when an intro_page is deleted" do
      intro_page_to_delete = decision_aid.intro_pages.second
      intro_page_to_delete.destroy
      orders = []
      decision_aid.intro_pages.each do |p|
        p.reload
        expect(p.intro_page_order).to be <= 5
        expect(p.intro_page_order).to be > 0
        expect(orders).not_to include(p.intro_page_order)
        orders.push p.intro_page_order
      end
      expect(decision_aid.intro_pages.map(&:intro_page_order).uniq.length).to eq(decision_aid.intro_pages.length)
    end
  end

  describe "injectable" do
    it_should_behave_like "injectable", :intro_page, :intro_page
  end

  #describe "has_attached_items" do
  #  it_should_behave_like "has_attached_items", :intro_page, :intro_page
  #end

  describe "user_stamps" do
    let (:decision_aid) { create(:basic_decision_aid) }
    it_behaves_like "user_stamps" do
      let (:item) { create(:intro_page, decision_aid_id: decision_aid.id) }
    end
  end
end
