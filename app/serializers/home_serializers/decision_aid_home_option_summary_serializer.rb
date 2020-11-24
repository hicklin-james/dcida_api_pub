class DecisionAidHomeOptionSummarySerializer < DecisionAidHomeOptionSerializer
  
  attributes :injected_summary_text_published,
    :sub_decision_order

  def injected_summary_text_published
    object.injected_summary_text_published(instance_options[:decision_aid_user])
  end

  def sub_decision_order
    object.sub_decision_order
  end

end