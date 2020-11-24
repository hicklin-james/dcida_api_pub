class DecisionAidHomeResultsSerializer < DecisionAidHomeSerializer

  attributes :injected_results_information_published, 
    :injected_properties_information_published,
    :ratings_enabled, 
    :percentages_enabled, 
    :best_match_enabled, 
    :bw_question_set_count,
    :dce_question_set_count,
    :options,
    :properties,
    :option_properties,
    :sub_decision

  def injected_results_information_published
    object.injected_results_information_published(instance_options[:decision_aid_user])
  end

  def injected_properties_information_published
    object.injected_properties_information_published(instance_options[:decision_aid_user]) if object.decision_aid_type == "traditional"
  end

  def sub_decision
    s = DecisionAidHomeSubDecisionSerializer.new(instance_options[:sub_decision], decision_aid_user: instance_options[:decision_aid_user])
    adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
    adapter.as_json
  end

  def options
    os = instance_options[:options]
    os.map do |o| 
      s = DecisionAidHomeOptionOptionsSerializer.new(o, decision_aid_user: instance_options[:decision_aid_user])
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    end
  end

  def properties
    #ps = object.sorted_properties(instance_options[:decision_aid_user])
    ps = object.properties.ordered
    ps.map do |p| 
      s = DecisionAidHomePropertyResultsSerializer.new(p, decision_aid_user: instance_options[:decision_aid_user])
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    end
  end

  def option_properties
    ops = object.option_properties.where(option_id: instance_options[:options].map(&:id))
    ops.map do |op| 
      s = DecisionAidHomeOptionPropertyResultsSerializer.new(op, decision_aid_user: instance_options[:decision_aid_user])
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    end
  end
end