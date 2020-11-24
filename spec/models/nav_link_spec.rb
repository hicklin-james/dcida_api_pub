# == Schema Information
#
# Table name: nav_links
#
#  id                 :integer          not null, primary key
#  link_href          :string
#  link_text          :string
#  link_location      :integer
#  nav_link_order     :integer          not null
#  decision_aid_id    :integer
#  created_by_user_id :integer
#  updated_by_user_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

RSpec.describe NavLink, type: :model do
  describe "validations" do
    let (:decision_aid) { create(:basic_decision_aid) }

    it "should save when all required attributes are set" do
      nl = build(:nav_link, decision_aid_id: decision_aid.id)
      expect(nl.save).to be true
    end

    it "should fail to save when decision_aid is not set" do
      nl = build(:nav_link)
      expect(nl.save).to be false
      expect(nl.errors.messages).to have_key :decision_aid_id
    end

    it "should fail to save when link_href is not set" do
      nl = build(:nav_link, decision_aid_id: decision_aid.id, link_href: nil)
      expect(nl.save).to be false
      expect(nl.errors.messages).to have_key :link_href
    end

    it "should fail to save when link_text is not set" do
      nl = build(:nav_link, decision_aid_id: decision_aid.id, link_text: nil)
      expect(nl.save).to be false
      expect(nl.errors.messages).to have_key :link_text
    end
  end
end
