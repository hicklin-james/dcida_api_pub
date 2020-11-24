class DecisionAidHomeDceSerializer < DecisionAidHomeSerializer

  attributes :injected_dce_information_published,
    :injected_dce_specific_information_published,
    :properties,
    :dce_question_set_responses,
    :dce_question_set_count,
    :injected_opt_out_information_published,
    :properties_auto_submit,
    :opt_out_label,
    :dce_option_prefix,
    :color_rows_based_on_attribute_levels,
    :compare_opt_out_to_last_selected,
    :dce_question_set_title,
    :injected_dce_confirmation_question_published,
    :include_dce_confirmation_question,
    :dce_type,
    :dce_selection_label,
    :dce_min_level_color,
    :dce_max_level_color

  def injected_dce_information_published
    object.injected_dce_information_published(instance_options[:decision_aid_user])
  end

  def injected_dce_specific_information_published
    object.injected_dce_specific_information_published(instance_options[:decision_aid_user])
  end

  def injected_opt_out_information_published
    object.injected_opt_out_information_published(instance_options[:decision_aid_user])
  end

  def injected_dce_confirmation_question_published
    object.injected_dce_confirmation_question_published(instance_options[:decision_aid_user])
  end

  def properties
    ps = object.properties.includes(:property_levels).ordered
    ps.map do |p| 
      s = DecisionAidHomePropertyDceSerializer.new(p, decision_aid_user: instance_options[:decision_aid_user])
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    end
  end

  def dce_question_set_title
    if cqs = instance_options[:current_question_set].to_i and cqs != 0
      dceqs = object.dce_question_sets.find_by(dce_question_set_order: cqs)
      if dceqs
        return dceqs.question_title
      end
    end
    return ""
  end

  def dce_question_set_responses
    if cqs = instance_options[:current_question_set].to_i and cqs != 0
      dceqsrs = object.dce_question_set_responses
        .where(question_set: cqs, block_number: instance_options[:decision_aid_user].randomized_block_number)
        .order(:response_value)
      dceqsrs.map do |dceqsr| 
        s = DecisionAidHomeDceQuestionSetResponseSerializer.new(dceqsr)
        adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
        adapter.as_json
      end
    else
      nil
    end
  end
end