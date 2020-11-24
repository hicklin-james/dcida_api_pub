class DecisionAidHomeQuestionResponseSerializer < ActiveModel::Serializer

  attributes :id,
    :question_id,
    :question_response_value,
    :is_text_response,
    :include_popup_information,
    :injected_popup_information_published
    #,:skip_page_url

  def injected_popup_information_published
    object.injected_popup_information_published(instance_options[:decision_aid_user])
  end

  # def skip_page_url
  #   if object.skip_logic_target_count > 0
  #     object.skip_logic_targets.first.skip_page_url
  #   else
  #     nil
  #   end
  # end
end

class DecisionAidHomeQuestionSerializer < ActiveModel::Serializer
  
  attributes :id,
    :question_text_published,
    :question_response_type,
    :question_responses,
    :grid_questions,
    :question_type,
    :question_response_style,
    :current_treatments,
    :question_id,
    :slider_left_label,
    :slider_right_label,
    :slider_midpoint_label,
    :slider_granularity,
    :can_change_response,
    :post_question_text_published,
    :unit_of_measurement,
    :side_text_published,
    :skippable,
    :special_flag,
    :is_exclusive,
    :min_number,
    :max_number,
    :min_chars,
    :max_chars,
    :units_array

  def question_text_published
    object.injected_question_text_published(instance_options[:decision_aid_user])
  end

  def post_question_text_published
    object.injected_post_question_text_published(instance_options[:decision_aid_user])
  end

  def side_text_published
    object.injected_side_text_published(instance_options[:decision_aid_user])
  end

  # def has_correct_answer
  #   r = object.send(:question_responses).find {|qr| qr.is_correct_value }
  #   !r.nil?
  # end

  def current_treatments
    #puts "\n\n\n\n"
    #puts instance_options[:decision_aid]
    #puts object.sub_decision_id
    if object.question_response_type == "current_treatment" and instance_options[:decision_aid]
      options = instance_options[:decision_aid]
        .relevant_options(instance_options[:decision_aid_user], nil, object.sub_decision_id)
        .order(:title)
        .where(id: object.current_treatment_option_ids)

      os = options.map do |o|
        s = DecisionAidHomeOptionSerializer.new(o)
        adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
        adapter.as_json
      end
      os.push Option.new(title: "Not Sure", id: 0)
      os
    else
      nil
    end
  end

  def question_responses
    qrs = object.question_responses

    if object.randomized_response_order
      qrs = qrs.shuffle
    end
    
    qrs.map do |qr| 
    	s = DecisionAidHomeQuestionResponseSerializer.new(qr, decision_aid_user: instance_options[:decision_aid_user])
    	adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
    	adapter.as_json
    end
  end

  def grid_questions
    if object.grid_questions_count > 0
      gqs = object.grid_questions.includes(:question_responses => [:skip_logic_targets])
      gqs.map do |q| 
        s = DecisionAidHomeQuestionSerializer.new(q, decision_aid_user: instance_options[:decision_aid_user])
        adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
        adapter.as_json
      end
    else
      []
    end
  end
end