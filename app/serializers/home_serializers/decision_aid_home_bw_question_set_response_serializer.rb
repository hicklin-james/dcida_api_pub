class DecisionAidHomeBwQuestionSetResponseSerializer < ActiveModel::Serializer
  
  attributes :id, 
    :question_set, 
    :decision_aid_id,
    :property_levels

  def property_levels
    pls = object.property_levels
    pls.map do |pl| 
      s = DecisionAidHomePropertyLevelBestWorstSerializer.new(pl, decision_aid_user: instance_options[:decision_aid_user])
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    end
  end
end