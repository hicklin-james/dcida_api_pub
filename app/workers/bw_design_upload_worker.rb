class BwDesignUploadWorker
  include Sidekiq::Worker

  def perform(decision_aid_id, user_id)
    decision_aid = DecisionAid.find decision_aid_id
    BwImport.new(decision_aid, user_id).import_design
  end
end