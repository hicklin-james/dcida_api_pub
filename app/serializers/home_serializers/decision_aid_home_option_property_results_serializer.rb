class DecisionAidHomeOptionPropertyResultsSerializer < DecisionAidHomeOptionPropertySerializer
  attributes :injected_information_published, 
    :ranking

  def ranking
    object.generate_ranking_value(instance_options[:decision_aid_user])
  end

  def short_label
    object.injected_short_label_published(instance_options[:decision_aid_user])
  end

  def injected_information_published
    object.injected_information_published(instance_options[:decision_aid_user])
  end
end