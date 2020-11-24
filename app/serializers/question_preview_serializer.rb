class QuestionResponsePreviewSerializer < ActiveModel::Serializer

  attributes :id,
    :question_response_value,
    :is_text_response,
    :decision_aid_id,
    :question_id,
    :redcap_response_value,
    :numeric_value,
    :include_popup_information,
    :popup_information

end

class QuestionPreviewSerializer < ActiveModel::Serializer
  
  attributes :id,
    :question_text_published,
    :question_type,
    :question_response_type,
    :decision_aid_id,
    :question_text_published,
    :question_order,
    :question_responses,
    :hidden,
    :response_value_calculation,
    :lookup_table,
    :lookup_table_dimensions,
    :question_response_style,
    :remote_data_source,
    :remote_data_source_type,
    :redcap_field_name,
    :my_sql_procedure_name,
    :current_treatments

  has_many :question_responses, serializer: QuestionResponsePreviewSerializer
  has_many :grid_questions, serializer: QuestionPreviewSerializer
    
  def current_treatments
    if object.question_response_type == "current_treatment"
      options = Option.where(id: object.current_treatment_option_ids)
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

end