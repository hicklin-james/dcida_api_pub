# == Schema Information
#
# Table name: decision_aid_user_sub_decision_choices
#
#  id                   :integer          not null, primary key
#  decision_aid_user_id :integer
#  sub_decision_id      :integer
#  option_id            :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

require 'rails_helper'

RSpec.describe DecisionAidUserSubDecisionChoice, type: :model do
  describe "update_next_sub_decision_choices_if_needed" do
    let (:decision_aid) { create(:full_decision_aid_with_sub_decisions) }
    let (:decision_aid_user) { create(:decision_aid_user, decision_aid_id: decision_aid.id) }
    
    it "should destroy decision_aid_user_sub_decision_choices if previous decision is not in required_option_ids" do
      sdcs = []
      for sd in decision_aid.sub_decisions.ordered do
        sdcs.push create(:decision_aid_user_sub_decision_choice, sub_decision_id: sd.id, option_id: decision_aid.options.where(sub_decision_id: sd.id).ordered.first.id, decision_aid_user_id: decision_aid_user.id)
      end
      expect(decision_aid_user.decision_aid_user_sub_decision_choices.count).to eq 2

      expect{
        sdc = sdcs.first
        sdc.option_id = decision_aid.options.where(sub_decision_id: sd.id).ordered.last.id
        sdc.save
      }.to change{decision_aid_user.decision_aid_user_sub_decision_choices.count}.by -1
    end

    it "should delete section trackers for deleted sub decision choices" do
      sdcs = []
      for sd in decision_aid.sub_decisions.ordered do
        sdcs.push create(:decision_aid_user_sub_decision_choice, sub_decision_id: sd.id, option_id: decision_aid.options.where(sub_decision_id: sd.id).ordered.first.id, decision_aid_user_id: decision_aid_user.id)
      end

      expect{
        sdc = sdcs.first
        sdc.option_id = decision_aid.options.where(sub_decision_id: sd.id).ordered.last.id
        sdc.save
      }.to change{decision_aid_user.progress_tracker.section_trackers.count}.by -1
    end

    it "should add new section tracker for new sub decision choice with next sub decision" do
      sdcs = []
      first_sd = decision_aid.sub_decisions.ordered.first
      
      expect{
        create(:decision_aid_user_sub_decision_choice, sub_decision_id: first_sd.id, option_id: decision_aid.options.where(sub_decision_id: first_sd.id).ordered.first.id, decision_aid_user_id: decision_aid_user.id)
      }.to change{decision_aid_user.progress_tracker.section_trackers.count}.by 1
    end
  end
end
