class DecisionAidHomeOptionPropertySerializer < ActiveModel::Serializer
  attributes :id, 
    :property_id, 
    :option_id,
    :short_label,
    :button_label
end