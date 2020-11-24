# == Schema Information
#
# Table name: summary_panels
#
#  id                                 :integer          not null, primary key
#  panel_type                         :integer
#  panel_information                  :text
#  panel_information_published        :text
#  question_ids                       :integer          default([]), is an Array
#  summary_panel_order                :integer
#  decision_aid_id                    :integer
#  created_by_user_id                 :integer
#  updated_by_user_id                 :integer
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  option_lookup_json                 :json
#  lookup_headers_json                :json
#  summary_table_header_json          :json
#  injectable_decision_summary_string :string
#  summary_page_id                    :integer          not null
#

require 'rails_helper'

RSpec.describe SummaryPanel, type: :model do
  describe "validations" do
    let (:decision_aid) { create(:basic_decision_aid) }

    it "should fail to save if decision_aid_id is missing" do
      sp = build(:summary_panel, panel_type: 0, summary_panel_order: 1)
      expect(sp.save).to be false
      expect(sp.errors.messages).to have_key :decision_aid_id
    end

    it "should fail to save if panel_type is missing" do
      sp = build(:summary_panel, decision_aid_id: decision_aid.id, summary_panel_order: 1)
      expect(sp.save).to be false
      expect(sp.errors.messages).to have_key :panel_type
    end

    it "should fail to save if summary_panel_order is missing" do
      sp = build(:summary_panel, decision_aid_id: decision_aid.id, panel_type: 0)
      expect(sp.save).to be false
      expect(sp.errors.messages).to have_key :summary_panel_order
    end
  end

  describe "injectable" do
    it_should_behave_like "injectable", :summary_panel, :summary_panel
  end

end
