class DecisionAidListSerializer < ActiveModel::Serializer

  attributes :id,
    :title,
    :slug,
    :description,
    :updated_at,
    :creator,
    :decision_aid_type

  def creator
    "#{object.creator.first_name} #{object.creator.last_name}" if object.creator
  end

end