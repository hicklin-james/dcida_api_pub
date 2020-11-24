class DecisionAidHomeAboutSerializer < DecisionAidHomeSerializer

  attributes :injected_about_information_published,
    :question_page

  # has_many :demographic_questions, key: :questions, serializer: DecisionAidHomeQuestionSerializer do
  #   object.demographic_questions.where(:question_id => nil, hidden: false).includes(:question_responses, :grid_questions => :question_responses).ordered
  # end

  def injected_about_information_published
    object.injected_about_information_published(instance_options[:decision_aid_user])
  end

  def question_page
    if instance_options[:question_page]
      s = DecisionAidHomeQuestionPageSerializer.new(instance_options[:question_page], decision_aid_user: instance_options[:decision_aid_user], decision_aid: instance_options[:decision_aid])
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    else
      nil
    end
  end

end