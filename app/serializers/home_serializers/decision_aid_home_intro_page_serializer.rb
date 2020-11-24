class DecisionAidHomeIntroPageSerializer < ActiveModel::Serializer
  
  attributes :id,
    :injected_description_published,
    :intro_page_order

  def injected_description_published
    object.injected_description_published(instance_options[:decision_aid_user])
  end

end