# == Schema Information
#
# Table name: latent_class_options
#
#  id              :integer          not null, primary key
#  latent_class_id :integer
#  option_id       :integer
#  weight          :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'rails_helper'

RSpec.describe LatentClassOption, type: :model do
  describe "validations" do
    let (:decision_aid) { create(:basic_decision_aid) }
    let (:latent_class) { create(:latent_class, decision_aid_id: decision_aid.id) }
    let (:option) { create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id) }

    it "should save when all required attributes are set" do
      lco = build(:latent_class_option, latent_class_id: latent_class.id, option_id: option.id)
      expect(lco.save).to be true
    end

    it "should fail to save if latent class is missing" do
      lco = build(:latent_class_option, option_id: option.id)
      expect(lco.save).to be false
      expect(lco.errors.messages).to have_key :latent_class_id
    end

    it "should fail to save if option is missing" do
      lco = build(:latent_class_option, latent_class_id: latent_class.id)
      expect(lco.save).to be false
      expect(lco.errors.messages).to have_key :option_id
    end

    it "should fail to save if weight is missing" do
      lco = build(:latent_class_option, latent_class_id: latent_class.id, option_id: option.id, weight: nil)
      expect(lco.save).to be false
      expect(lco.errors.messages).to have_key :weight
    end
  end
end
