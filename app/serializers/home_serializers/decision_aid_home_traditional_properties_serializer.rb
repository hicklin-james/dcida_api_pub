class DecisionAidHomeTraditionalPropertiesSerializer < DecisionAidHomeSerializer

  attributes :injected_properties_information_published,
    :minimum_property_count,
    :injected_property_weight_information_published,
    :maximum_property_count,
    :chart_type,
    :properties,
    :options,
    :option_properties

  def properties
    ps = object.properties.ordered
    ps.map do |p| 
      s = DecisionAidHomePropertyPropertiesSerializer.new(p, decision_aid_user: instance_options[:decision_aid_user])
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    end
  end

  def injected_properties_information_published
    object.injected_properties_information_published(instance_options[:decision_aid_user])
  end

  def injected_property_weight_information_published
    object.injected_property_weight_information_published(instance_options[:decision_aid_user])
  end

  def options
    os = instance_options[:options]
    os.map do |o| 
      s = DecisionAidHomeOptionOptionsSerializer.new(o, decision_aid_user: instance_options[:decision_aid_user])
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