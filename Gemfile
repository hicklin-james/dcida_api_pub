source 'http://rubygems.org'

ruby "2.6.3"
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.4.1'
# Use postgres as the database for Active Record
gem 'pg', '~> 1.2.2'
# remove rails elements that are unused by API applications
# gem 'rails-api', '~> 0.4.0'
# Use CoffeeScript for .coffee assets and views
# gem 'coffee-rails', '~> 4.1.0'
# write serializer modules that define how a model object is transformed into JSON
gem 'active_model_serializers',  :git => 'https://github.com/rails-api/active_model_serializers.git', :tag => "v0.10.0.rc5"
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'rb-readline'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 1.0.0', group: :doc

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'
# gem 'w3c_validators'

# OAuth provider implementation
gem 'doorkeeper', '~> 4.2.6'

gem 'useragent', '~> 0.16.10'

# authorization policy management
gem 'pundit', '~> 0.2.3'

# API documentation
gem 'apipie-rails', '~> 0.5.17' #github: 'Apipie/apipie-rails', ref: '928bd858fd14ec67eeb9483ba0d43b3be8339608'

gem 'request_store', '1.0.5'

# paperclip image & media uploading
gem "paperclip", "~> 6.1.0"

gem 'sinatra', :require => nil

# fast blank method
gem "fast_blank"
# pagination
gem 'kaminari'

gem 'listen'

# cors
gem 'rack-cors', require: 'rack/cors'

gem "counter_culture", "~> 0.1.33"

gem "whenever", "~> 0.9.4"

gem 'sidekiq', '~> 5.2.8'

gem 'newrelic_rpm', '~> 6.8.0.360'

gem 'rubyzip'

gem 'unirest', '~> 1.1.2'
  
# multi table inheritance
gem 'active_record-acts_as', '~> 2.0.9'

gem 'faye-websocket', '0.10.0'
gem 'websocket-rails', '~> 0.7.0'
gem 'redis-objects', '~> 1.3.0'
gem 'redis', '3.3.5'

gem 'deep_cloneable', '~> 3.0.0'

gem 'oj'
gem 'oj_mimic_json' # we need this for Rails 4.1.x

gem 'pdfkit'

gem 'rails_12factor', group: :production

gem 'mysql2'

gem 'nokogiri'

gem 'betterlorem'

group :profile do
  gem 'ruby-prof'
end

group :development do
  # annotate model rb files with column names from DB schema
  gem 'annotate', '~> 3.0.3'
  # colored console output
  gem "colorize"
  gem 'foreman'
  gem 'rails-erd'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  gem 'rdoc'
  gem 'bullet'
end

group :development, :test, :e2e_test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem "parallel_tests", '~> 2.31.0'
  
  gem 'rspec-rails', '~> 3.8.3' # must be in development group to run rake task
  
  gem 'database_cleaner'
end

group :test, :e2e_test do

  gem 'factory_girl_rails', '~> 4.5.0'
  #gem 'test_after_commit', '~> 1.2.2'

  gem 'simplecov', "~> 0.18.2"
  gem 'rspec-sidekiq', '~> 3.0.2'

  #gem 'hangar', git: "https://github.com/faradayio/hangar.git"
end

group :deployment do 
  gem 'capistrano-bundler'
  gem 'capistrano-sidekiq'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'capistrano', '~> 3.3.5'
  gem 'capistrano_colors'
  gem 'capistrano3-unicorn'
  gem 'capistrano-websocket-rails'
  gem 'unicorn'
  gem 'unicorn-worker-killer'
end

