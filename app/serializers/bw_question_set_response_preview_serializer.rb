class BwQuestionSetResponsePreviewSerializer < ActiveModel::Serializer

  attributes :id, 
    :question_set,
    :property_level_ids,
    :decision_aid_id,
    :property_levels

  # def property_levels
  #   pls = object.property_levels
  #   pls.map do |pl| 
  #     s = PropertyLevelPreviewSerializer.new(pl)
  #     adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
  #     adapter.as_json
  #   end
  # end

end