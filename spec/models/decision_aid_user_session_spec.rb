# == Schema Information
#
# Table name: decision_aid_user_sessions
#
#  id                   :integer          not null, primary key
#  decision_aid_user_id :integer          not null
#  last_access          :datetime         not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

require "rails_helper"

RSpec.describe DecisionAidUserSession, :type => :model do

  let (:decision_aid) { create(:basic_decision_aid) }
  let (:decision_aid_user) { create(:decision_aid_user, decision_aid: decision_aid) } 

  describe "methods" do

    describe "::create_or_update_user_session" do
      it "should create a new session if one doesn't exist for the user" do
        expect{DecisionAidUserSession::create_or_update_user_session(decision_aid_user.id)}
          .to change{DecisionAidUserSession.count}.by 1
      end

      it "shouldn't create a new session if one already exists" do
        DecisionAidUserSession::create_or_update_user_session(decision_aid_user.id)
        expect{DecisionAidUserSession::create_or_update_user_session(decision_aid_user.id)}
          .not_to change{DecisionAidUserSession.count}
      end

      it "should update the last_access to now" do
        session = create(:decision_aid_user_session, last_access: 2.days.ago, decision_aid_user_id: decision_aid_user.id)
        expect(session.last_access.today?).to be false
         DecisionAidUserSession::create_or_update_user_session(decision_aid_user.id)
         expect(session.reload.last_access.today?).to be true
      end
    end

    describe "::remove_old_sessions" do
      it "should clear out sessions older than 1 day ago" do
        session = create(:decision_aid_user_session, last_access: 2.days.ago, decision_aid_user_id: decision_aid_user.id)
        expect(DecisionAidUserSession.count).to eq 1
        DecisionAidUserSession::remove_old_sessions
        expect(DecisionAidUserSession.count).to eq 0
      end

      it "should not delete sessions newer than 1 day ago" do
        session = create(:decision_aid_user_session, last_access: 2.hours.ago, decision_aid_user_id: decision_aid_user.id)
        expect(DecisionAidUserSession.count).to eq 1
        DecisionAidUserSession::remove_old_sessions
        expect(DecisionAidUserSession.count).to eq 1
      end
    end
  end

end
