class DecisionAidMailWorker
  include Sidekiq::Worker

  def perform(daid, dauid, html, send_address)
    DecisionAidMailer.summary_mail(daid, dauid, html, send_address).deliver_now
  end
end