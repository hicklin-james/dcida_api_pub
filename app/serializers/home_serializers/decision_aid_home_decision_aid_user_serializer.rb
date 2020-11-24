class DecisionAidHomeDecisionAidUserSerializer < ActiveModel::Serializer
  attributes :id,
    :decision_aid_id,
    :selected_option_id,
    :pid,
    :decision_aid_user_responses_count,
    :decision_aid_user_properties_count,
    :decision_aid_user_option_properties_count,
    :decision_aid_user_dce_question_set_responses_count,
    :decision_aid_user_bw_question_set_responses_count

  # def pid
  #   object.decision_aid_user_query_parameters.joins("LEFT OUTER JOIN decision_aid_query_parameters as daqp on decision_aid_user_query_parameters.id = daqp.id AND daqp.is_primary = true").select("decision_aid_user_query_parameters.param_value").param_value
  # end

end