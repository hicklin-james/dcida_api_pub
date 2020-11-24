# == Schema Information
#
# Table name: icons
#
#  id                 :integer          not null, primary key
#  decision_aid_id    :integer          not null
#  url                :string
#  icon_type          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#  created_by_user_id :integer
#  updated_by_user_id :integer
#

require "rails_helper"

RSpec.describe Icon, :type => :model do
  let (:decision_aid) { create(:basic_decision_aid) }

  describe "validations" do
    it "should fail to save if decision_aid_id is missing" do
      icon = build(:icon)
      expect(icon.save).to be false
      expect(icon.errors.messages).to have_key :decision_aid_id
    end

    it "should save if all validated attributes exist" do
      icon = build(:icon, decision_aid_id: decision_aid.id)
      expect(icon.save).to be true
    end
  end
end
