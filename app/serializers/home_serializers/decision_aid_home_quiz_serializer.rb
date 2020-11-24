class DecisionAidHomeQuizSerializer < DecisionAidHomeSerializer

  attributes :injected_quiz_information_published,
    :question_page,
    :bw_question_set_count,
    :dce_question_set_count

  # has_many :quiz_questions, key: :questions, serializer: DecisionAidHomeQuestionSerializer do
  #   object.quiz_questions
  #     .where(:question_id => nil, hidden: false)
  #     .includes(:question_responses, :grid_questions => :question_responses)
  #     .ordered
  # end

  def injected_quiz_information_published
    object.injected_quiz_information_published(instance_options[:decision_aid_user])
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