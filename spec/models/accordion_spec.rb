# == Schema Information
#
# Table name: accordions
#
#  id               :integer          not null, primary key
#  title            :string           not null
#  decision_aid_ids :integer          default([]), is an Array
#  user_id          :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  decision_aid_id  :integer
#

require "rails_helper"

RSpec.describe Accordion, :type => :model do
  let (:user) { create(:user) }
  let (:decision_aid) { create(:full_decision_aid, slug: "test_decision_aid") }
  let (:accordion) { create(:accordion, user_id: user.id) }

  describe "validations" do
    it "shouldn't save if decision aid id is nil" do
      acc = build(:accordion, decision_aid_id: nil, user_id: user.id)
      expect(acc.save).to be false
    end

    it "shouldn't save if user id is nil" do
      acc = build(:accordion, decision_aid_id: decision_aid.id)
      expect(acc.save).to be false
    end
  end
end
