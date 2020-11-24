class UserDataExportWorker
  include Sidekiq::Worker

  def perform(decision_aid_id, download_item_id, user_id, export_data)
    da = DecisionAid.find decision_aid_id
    di = DownloadItem.find download_item_id

    UserDataExport.new(da, di, user_id, export_data).export

  end
end