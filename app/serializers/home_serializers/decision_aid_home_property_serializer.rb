class DecisionAidHomePropertySerializer < ActiveModel::Serializer

  attributes :id,
    :title,
    :property_order,
    :short_label,
    :are_option_properties_weighable

end