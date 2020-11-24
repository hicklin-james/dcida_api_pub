class SummaryEmailWorker
  include Sidekiq::Worker

  def perform(decision_aid_user_id)
    dau = DecisionAidUser.find(decision_aid_user_id)
    decision_aid = dau.decision_aid
    dausps = DecisionAidUserSummaryPage
      .joins("LEFT OUTER JOIN summary_pages spa ON ( spa.id = decision_aid_user_summary_pages.summary_page_id )")
      .where(decision_aid_user_id: dau.id)
      .where("spa.include_admin_summary_email = 't'")
      .select("decision_aid_user_summary_pages.*",
               "spa.summary_email_addresses AS summary_email_addresses", 
               "spa.decision_aid_id AS decision_aid_id")

    dausps.each do |dausp|
      DecisionAidMailer.non_primary_summary_mail(dausp, decision_aid).deliver_now
    end
  end
end