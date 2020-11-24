# == Schema Information
#
# Table name: latent_classes
#
#  id                 :integer          not null, primary key
#  decision_aid_id    :integer
#  class_order        :integer
#  created_by_user_id :integer
#  updated_by_user_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

RSpec.describe LatentClass, type: :model do
  describe "validations" do
    let (:decision_aid) { create(:basic_decision_aid) }

    it "should save when all required attributes are set" do
      lc = build(:latent_class, decision_aid_id: decision_aid.id)
      expect(lc.save).to be true
    end

    it "should fail to save if decision aid is missing" do
      lc = build(:latent_class)
      expect(lc.save).to be false
      expect(lc.errors.messages).to have_key :decision_aid_id
    end
  end
end
