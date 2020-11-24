class DecisionAidHomeSummarySerializer < DecisionAidHomeSerializer

  attributes :options,
    :properties,
    :option_properties,
    :sub_decisions,
    :summary_panels,
    :summary_link_to_url,
    :more_information_button_text,
    :injected_final_summary_text_published,
    :bw_question_set_count,
    :dce_question_set_count,
    :include_admin_summary_email,
    :include_user_summary_email,
    :user_summary_email_text,
    :include_download_pdf_button,
    :open_summary_link_in_new_tab

  has_many :questions, key: :questions, serializer: DecisionAidHomeQuestionSerializer do
    object.questions
      .where(:question_id => nil, hidden: false)
      .includes(:question_responses => [:skip_logic_targets => :skip_logic_conditions], 
                :grid_questions => :question_responses)  
  end

  has_many :sub_decisions, serializer: DecisionAidHomeSubDecisionSummarySerializer

  def injected_final_summary_text_published
    object.injected_final_summary_text_published(instance_options[:decision_aid_user])
  end

  def summary_link_to_url
    if object.summary_link_to_url and !object.summary_link_to_url.blank?
      daqps = instance_options[:decision_aid_user].decision_aid_user_query_parameters.includes(:decision_aid_query_parameter)
      if instance_options[:decision_aid_user] and daqps.count > 0
        qps = daqps.map{|qp| "#{qp.decision_aid_query_parameter.output_name}=#{qp.param_value}"}.join("&")
        object.summary_link_to_url + qps
      else
        object.summary_link_to_url
      end
    else
      nil
    end
  end

  def injected_results_information_published
    object.injected_results_information_published(instance_options[:decision_aid_user])
  end

  def options
    os = instance_options[:options]
    os.map do |o| 
      s = DecisionAidHomeOptionSummarySerializer.new(o, decision_aid_user: instance_options[:decision_aid_user])
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    end
  end

  def properties
    ps = object.sorted_properties(instance_options[:decision_aid_user])
    ps.map do |p| 
      s = DecisionAidHomePropertySerializer.new(p)
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    end
  end

  def option_properties
    ops = object.option_properties.where(option_id: instance_options[:options].map(&:id))
    ops.map do |op| 
      s = DecisionAidHomeOptionPropertySerializer.new(op)
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    end
  end

  def summary_panels
    sps = object.summary_panels.primary.ordered
    sps.map do |sp|
      s = DecisionAidHomeSummaryPanelSerializer.new(sp, decision_aid_user: instance_options[:decision_aid_user])
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    end
  end
end