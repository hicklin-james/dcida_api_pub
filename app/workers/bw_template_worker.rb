class BwTemplateWorker
  include Sidekiq::Worker

  def perform(num_questions, num_attributes_per_question, num_blocks, decision_aid_id, download_item_id, user_id)
    decision_aid = DecisionAid.find decision_aid_id
    download_item = DownloadItem.find download_item_id
    ExportBw.new(decision_aid, download_item, user_id, num_questions, num_attributes_per_question, num_blocks).create_bw_template_files
  end
end