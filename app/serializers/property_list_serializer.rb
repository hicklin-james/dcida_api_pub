class PropertyListSerializer < ActiveModel::Serializer

  attributes :id,
    :title,
    :selection_about,
    :long_about,
    :decision_aid_id,
    :property_order

end