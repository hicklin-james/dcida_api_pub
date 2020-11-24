# == Schema Information
#
# Table name: summary_pages
#
#  id                          :integer          not null, primary key
#  decision_aid_id             :integer          not null
#  summary_panels_count        :integer          default(0), not null
#  include_admin_summary_email :boolean          default(FALSE)
#  is_primary                  :boolean          default(FALSE)
#  summary_email_addresses     :string           is an Array
#  created_by_user_id          :integer
#  updated_by_user_id          :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  backend_identifier          :string
#

require 'rails_helper'

RSpec.describe SummaryPage, type: :model do
  describe "validations" do
    let (:decision_aid) { create(:basic_decision_aid) }

    it "should fail to save if decision_aid_id is missing" do
      summary_page = build(:summary_page)
      expect(summary_page.save).to be false
      expect(summary_page.errors.messages).to have_key :decision_aid_id
    end
  end
end
