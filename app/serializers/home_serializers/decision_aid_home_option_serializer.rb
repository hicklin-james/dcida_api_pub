class DecisionAidHomeOptionSerializer < ActiveModel::Serializer
  
  attributes :id,
    :title,
    :original_image_url,
    :results_image_url,
    :sub_decision_id,
    :ct_order,
    :option_order,
    :label,
    :generic_name

  def ct_order
    object.respond_to?(:ct_order) ? object.ct_order : nil
  end

end