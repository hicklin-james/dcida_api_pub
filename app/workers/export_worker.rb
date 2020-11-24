class ExportWorker
  include Sidekiq::Worker

  def perform(decision_aid_id, download_file_id, user_id)
    da = DecisionAid.find decision_aid_id
    df = DownloadItem.find download_file_id

    ExportCsv.new(da, df, user_id).export

  end
end