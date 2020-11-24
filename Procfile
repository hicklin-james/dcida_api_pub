redis: redis-server
sidekiq: bundle exec sidekiq -e ${RAILS_ENV:-development} -C config/sidekiq_main.yml
sidekiq: bundle exec sidekiq -e ${RAILS_ENV:-development} -C config/sidekiq_data_exports.yml
server: bundle exec rails s -b 0.0.0.0 -p 3000
websocketrails: bin/websockets

