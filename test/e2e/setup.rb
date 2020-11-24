require_relative 'decision_aid/standard_decision_aid.rb'

class E2E
  attr_reader :decision_aid_to_load

  def initialize(decision_aid_to_load)
    @decision_aid_to_load = decision_aid_to_load  
  end

  def setup_e2e_env_for_test(additional_params)
    case @decision_aid_to_load
    when "standard_decision_aid"
      E2EStandardDecisionAid.new.seed(additional_params)
    end
  end

end
