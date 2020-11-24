class DecisionAidHomePropertiesSerializer < DecisionAidHomeSerializer

  attributes :injected_properties_information_published,
    :injected_property_weight_information_published,
    :minimum_property_count,
    :maximum_property_count,
    :chart_type,
    :properties,
    :option_properties

  def properties
    ps = object.properties.ordered.where(:is_property_weighable => true)
    ps.map do |p| 
      s = DecisionAidHomePropertyPropertiesSerializer.new(p, decision_aid_user: instance_options[:decision_aid_user])
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    end
  end

  def option_properties
    if instance_options[:decision_aid] && instance_options[:decision_aid].decision_aid_type == 'standard_enhanced'
      option_ids = object.relevant_options(instance_options[:decision_aid_user]).map(&:id)
      ops = object.option_properties.where(option_id: option_ids)
      ops.map do |op| 
        s = DecisionAidHomeOptionPropertyResultsSerializer.new(op, decision_aid_user: instance_options[:decision_aid_user])
        adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
        adapter.as_json
      end
    else
      []
    end
  end

  def injected_properties_information_published
    object.injected_properties_information_published(instance_options[:decision_aid_user])
  end

  def injected_property_weight_information_published
    object.injected_property_weight_information_published(instance_options[:decision_aid_user])    
  end

end