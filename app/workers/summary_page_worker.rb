class SummaryPageWorker
  include Sidekiq::Worker

  def perform(decision_aid_user_id)
    dau = DecisionAidUser.find_by(id: decision_aid_user_id)
    dts = DataExportField.where(decision_aid_id: dau.decision_aid_id,
                                exporter_type: "SummaryPage")
                         .select("data_export_fields.id, 
                                  data_export_fields.exporter_id")

    sps = DecisionAidUserSummaryPage.generateForDecisionAidUser(dau, dts.map(&:exporter_id))

    # trigger summary page emails
    dau.trigger_summary_page_emails

    # trigger remote data target work
    if dts.length > 0
      DataTargetExportWorker.perform_async(dts.map(&:id), dau.id)
    end
  end
end