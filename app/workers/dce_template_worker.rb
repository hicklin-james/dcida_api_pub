class DceTemplateWorker
  include Sidekiq::Worker

  def perform(num_questions, num_responses, num_blocks, include_opt_out, decision_aid_id, download_item_id, user_id)
    decision_aid = DecisionAid.find decision_aid_id
    download_item = DownloadItem.find download_item_id
    ExportDce.new(decision_aid, download_item, user_id, num_questions, num_responses, num_blocks, include_opt_out).create_dce_template_files
  end
end