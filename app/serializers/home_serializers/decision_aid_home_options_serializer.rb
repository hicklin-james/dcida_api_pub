class DecisionAidHomeOptionsSerializer < DecisionAidHomeSerializer

  attributes :relevant_options,
    :sub_decision

  def injected_options_information_published
    object.injected_options_information_published(instance_options[:decision_aid_user])
  end

  def injected_other_options_information_published
    object.injected_other_options_information_published(instance_options[:decision_aid_user])
  end

  def relevant_options
    #sub_decision = SubDecision.find_by(decision_aid_id: instance_options[:decision_aid_user].decision_aid_id, sub_decision_order: instance_options[:sub_decision_order])
    os = object.relevant_options(instance_options[:decision_aid_user], nil, instance_options[:sub_decision].id).includes(:media_file)
    os.map do |o| 
      s = DecisionAidHomeOptionOptionsSerializer.new(o, decision_aid_user: instance_options[:decision_aid_user])
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    end
  end

  def sub_decision
    s = DecisionAidHomeSubDecisionSerializer.new(instance_options[:sub_decision], decision_aid_user: instance_options[:decision_aid_user])
    adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
    adapter.as_json
  end

end