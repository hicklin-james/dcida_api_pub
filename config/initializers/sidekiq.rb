require 'sidekiq/api'

Sidekiq.configure_server do |config|
  Rails.logger = Sidekiq::Logging.logger
  
  # workers = Sidekiq::Workers.new
  # Rails.logger.debug "Sidekiq worker size: <#{workers.size}>"

  # workers.each do |pid, tid, work|
  #   Rails.logger.debug "Sidekiq worker has process_id <#{pid}> and thread_id <#{tid}>"
  # end
end