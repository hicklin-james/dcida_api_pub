require_relative '../../test/e2e/setup.rb'
require 'database_cleaner'

class TestController < ApplicationController
  
  def setup_e2e_env
    #if Rails.env.test?

      puts "Clearing data!"
      DatabaseCleaner.strategy = :deletion
      DatabaseCleaner.clean
      puts "Data cleared"

      #Rails.application.load_seed

      Rails.logger.debug "Params: #{params.inspect}"

      E2E.new(params["decision_aid_to_load"]).setup_e2e_env_for_test(params["additional_params"])
    #end
    render json: { message: "removed" }, status: :ok
  end
end