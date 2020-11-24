class DecisionAidHomePropertyDceSerializer < DecisionAidHomePropertySerializer
  
  attributes :property_levels,
    :selection_about,
    :injected_long_about_published

  def property_levels
    pls = object.property_levels
    pls.map do |pl| 
      s = DecisionAidHomePropertyLevelSerializer.new(pl, decision_aid_user: instance_options[:decision_aid_user])
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    end
  end

  def injected_long_about_published
    object.injected_long_about_published(instance_options[:decision_aid_user])
  end

end