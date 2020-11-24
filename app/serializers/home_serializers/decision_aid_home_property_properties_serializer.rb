class DecisionAidHomePropertyPropertiesSerializer < DecisionAidHomePropertySerializer
  
  attributes :injected_selection_about_published,
    :injected_long_about_published

  def injected_selection_about_published
    object.injected_selection_about_published(instance_options[:decision_aid_user])
  end

  def injected_long_about_published
    object.injected_long_about_published(instance_options[:decision_aid_user])
  end

end