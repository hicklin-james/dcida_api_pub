class QuestionListSerializer < ActiveModel::Serializer
  attributes :id,
    :question_text,
    :question_type,
    :question_response_type,
    :decision_aid_id,
    :question_order,
    :hidden,
    :remote_data_source,
    :question_page_id
end