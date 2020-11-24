if defined? NewRelic

  class ActionController::API
    include NewRelic::Agent::Instrumentation::ControllerInstrumentation
    #include NewRelic::Agent::Instrumentation::Rails4::ActionController
  end
end