class DecisionAidHomePropertyLevelSerializer < ActiveModel::Serializer
  
  attributes :id, 
    :level_id, 
    :property_id,
    :injected_information_published

  def injected_information_published
    object.injected_information_published(instance_options[:decision_aid_user])
  end

end