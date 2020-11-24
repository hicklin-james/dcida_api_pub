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

class DecisionAidUserSession < ApplicationRecord

  belongs_to :decision_aid_user

  def self.create_or_update_user_session(decision_aid_user_id)
    query = DecisionAidUserSession.where(decision_aid_user_id: decision_aid_user_id)
    if query.length > 0
      session = query.first
      session.last_access = Time.now
      session.save
    else
      DecisionAidUserSession.create(decision_aid_user_id: decision_aid_user_id, last_access: Time.now)
      dau = DecisionAidUser.includes(:decision_aid).find(decision_aid_user_id)
      dau.update_progress_tracker(dau.decision_aid)
    end
  end

  def self.remove_old_sessions
    old_sessions = DecisionAidUserSession.where("last_access < ?", 1.days.ago)
    old_sessions.destroy_all
  end
end
