# == Schema Information
#
# Table name: latent_class_properties
#
#  id              :integer          not null, primary key
#  latent_class_id :integer
#  property_id     :integer
#  weight          :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'rails_helper'

RSpec.describe LatentClassProperty, type: :model do
  describe "validations" do
    let (:decision_aid) { create(:basic_decision_aid) }
    let (:latent_class) { create(:latent_class, decision_aid_id: decision_aid.id) }
    let (:property) { create(:property, decision_aid_id: decision_aid.id) }

    it "should save when all required attributes are set" do
      lcp = build(:latent_class_property, latent_class_id: latent_class.id, property_id: property.id)
      expect(lcp.save).to be true
    end

    it "should fail to save if latent class is missing" do
      lcp = build(:latent_class_property, property_id: property.id)
      expect(lcp.save).to be false
      expect(lcp.errors.messages).to have_key :latent_class_id
    end

    it "should fail to save if property is missing" do
      lcp = build(:latent_class_property, latent_class_id: latent_class.id)
      expect(lcp.save).to be false
      expect(lcp.errors.messages).to have_key :property_id
    end

    it "should fail to save if weight is missing" do
      lcp = build(:latent_class_property, latent_class_id: latent_class.id, property_id: property.id, weight: nil)
      expect(lcp.save).to be false
      expect(lcp.errors.messages).to have_key :weight
    end
  end
end
