class DecisionAidHomeQuestionPageSerializer < ActiveModel::Serializer

  attributes :id,
    :section,
    :question_page_order,
    :questions

  def questions
    object.questions.ordered.map do |q|
      s = DecisionAidHomeQuestionSerializer.new(q, decision_aid_user: instance_options[:decision_aid_user], decision_aid: instance_options[:decision_aid])
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    end
  end
end