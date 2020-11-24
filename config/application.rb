require_relative 'boot'

#require 'rails/all'
require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

require 'oj'

Oj.mimic_JSON()

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dcida20Api
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.load_defaults 5.0

    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'local_env.yml')
      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exists?(env_file)
    end

    ActiveModelSerializers.config.adapter = :json
    ActiveModelSerializers.config.key_transform = :underscore

    # Do not swallow errors in after_commit/after_rollback callbacks.
    # config.active_record.raise_in_transactional_callbacks = true

    config.autoload_paths += Dir[File.join(config.root, 'lib', '**', '')]
    config.autoload_paths += Dir[ Rails.root.join('app', 'models', '**/') ] 
    config.autoload_paths += Dir[ Rails.root.join('app', 'serializers', '**/') ] 

    config.middleware.delete Rack::Lock

    config.active_job.queue_adapter = :sidekiq

    # CORS config
    config.middleware.insert_before 0, Rack::Cors, :debug => true, :logger => Rails.logger do
      allow do
        origins '*'

        resource '/cors',
          :headers => :any,
          :methods => [:post],
          :credentials => false,
          :max_age => 0

        # resource '/websocket',
        #   :headers => :any,
        #   :methods => [:get],
        #   :max_age => 0

        resource '*',
          :headers => :any,
          :methods => [:get, :post, :delete, :put, :options, :head],
          :max_age => 0
      end
    end

  end
end
