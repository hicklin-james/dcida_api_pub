class ProgressTrackerWorker
  include Sidekiq::Worker

  def perform(decision_aid_id, flag)
    decision_aid = DecisionAid.find decision_aid_id

    decision_aid_user_ids = DecisionAidUser.where(decision_aid_id: decision_aid_id).pluck(:id)
    sessions = DecisionAidUserSession.where(decision_aid_user_id: decision_aid_user_ids)
    sessions.each do |s|
      begin
        s.decision_aid_user.update_progress_tracker(decision_aid, flag)
      rescue
        Rails.logger.error "An error occured while updating progress tracker for decision aid user #{s.decision_aid_user.id}"
      end
    end
  end
end