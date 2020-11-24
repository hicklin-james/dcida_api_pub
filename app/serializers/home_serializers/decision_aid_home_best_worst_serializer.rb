class DecisionAidHomeBestWorstSerializer < DecisionAidHomeSerializer

  attributes :injected_best_worst_information_published,
    :injected_best_worst_specific_information_published,
    :properties,
    :bw_question_set_response,
    :bw_question_set_count,
    :best_wording,
    :worst_wording,
    :properties_auto_submit

  def injected_best_worst_information_published
    object.injected_best_worst_information_published(instance_options[:decision_aid_user])
  end

  def injected_best_worst_specific_information_published
    object.injected_best_worst_specific_information_published(instance_options[:decision_aid_user])
  end

  def properties
    ps = object.properties.sort_by{|p| p.property_order}
    ps.map do |p| 
      s = DecisionAidHomePropertyDceSerializer.new(p, decision_aid_user: instance_options[:decision_aid_user])
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    end
  end

  def bw_question_set_response
    if cqs = instance_options[:current_question_set].to_i and cqs != 0
      bwqsrs = object.bw_question_set_responses
        .where(question_set: cqs, block_number: instance_options[:decision_aid_user].randomized_block_number)
      
      # if nothing found, ignore block number and just use first one
      if bwqsrs.length == 0
        puts "Decision aid user id <#{instance_options[:decision_aid_user].id}> with block number <#{instance_options[:decision_aid_user].randomized_block_number}> not found"
        bwqsrs =   object.bw_question_set_responses.where(question_set: cqs, block_number: 1)
      end

      if bwqsrs.length > 0 and bwqrs = bwqsrs.first
        s = DecisionAidHomeBwQuestionSetResponseSerializer.new(bwqrs, decision_aid_user: instance_options[:decision_aid_user])
        adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
        adapter.as_json
      else
        nil
      end
    else
      nil
    end
  end
end