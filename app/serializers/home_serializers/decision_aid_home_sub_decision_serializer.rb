class DecisionAidHomeSubDecisionSerializer < ActiveModel::Serializer

  attributes :injected_options_information_published,
    :injected_other_options_information_published,
    :id,
    :sub_decision_order,
    :decision_aid_id,
    :injected_my_choice_information_published,
    :option_question_text

  def injected_my_choice_information_published
    object.injected_my_choice_information_published(instance_options[:decision_aid_user])
  end

  def injected_options_information_published
    object.injected_options_information_published(instance_options[:decision_aid_user])
  end

  def injected_other_options_information_published
    object.injected_other_options_information_published(instance_options[:decision_aid_user])
  end

end