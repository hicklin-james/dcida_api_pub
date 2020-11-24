class ApplicationMailer < ActionMailer::Base
  default from: ENV['MAILER_BASE']
  layout 'mailer'
end
