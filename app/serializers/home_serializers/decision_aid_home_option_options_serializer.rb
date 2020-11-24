class DecisionAidHomeOptionOptionsSerializer < DecisionAidHomeOptionSerializer
  
  attributes :injected_description_published,
    :ct_order

  def injected_description_published
    object.injected_description_published(instance_options[:decision_aid_user])
  end

end