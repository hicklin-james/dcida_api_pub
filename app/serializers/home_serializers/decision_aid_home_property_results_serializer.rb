class DecisionAidHomePropertyResultsSerializer < DecisionAidHomePropertySerializer
  attributes :injected_long_about_published,
  	:property_group_title

  def injected_long_about_published
    object.injected_long_about_published(instance_options[:decision_aid_user])
  end
end
