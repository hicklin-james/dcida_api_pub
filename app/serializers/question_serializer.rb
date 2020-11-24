# == Schema Information
#
# Table name: questions
#
#  id                           :integer          not null, primary key
#  question_text                :text
#  question_type                :integer          not null
#  question_response_type       :integer          not null
#  question_order               :integer          not null
#  decision_aid_id              :integer          not null
#  created_by_user_id           :integer
#  updated_by_user_id           :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  question_text_published      :text
#  question_id                  :integer
#  grid_questions_count         :integer          default(0), not null
#  hidden                       :boolean          default(FALSE)
#  response_value_calculation   :string
#  lookup_table                 :json
#  question_response_style      :integer
#  sub_decision_id              :integer
#  lookup_table_dimensions      :integer          default([]), is an Array
#  remote_data_source           :boolean          default(FALSE)
#  remote_data_source_type      :integer
#  redcap_field_name            :string
#  my_sql_procedure_name        :string
#  current_treatment_option_ids :integer          default([]), is an Array
#  slider_left_label            :string
#  slider_right_label           :string
#  slider_granularity           :integer
#  num_decimals_to_round_to     :integer          default(0)
#  can_change_response          :boolean          default(TRUE)
#  post_question_text           :text
#  post_question_text_published :text
#  slider_midpoint_label        :string
#  unit_of_measurement          :string
#  side_text                    :text
#  side_text_published          :text
#  skippable                    :boolean          default(FALSE)
#  special_flag                 :integer          default(1), not null
#  is_exclusive                 :boolean          default(FALSE)
#  randomized_response_order    :boolean          default(FALSE)
#  min_number                   :integer
#  max_number                   :integer
#  min_chars                    :integer
#  max_chars                    :integer
#  units_array                  :string           default([]), is an Array
#  remote_data_target           :boolean          default(FALSE)
#  remote_data_target_type      :integer
#  backend_identifier           :string
#  question_page_id             :integer
#

class QuestionResponseSerializer < ActiveModel::Serializer

  attributes :id,
    :question_response_value,
    :is_text_response,
    :decision_aid_id,
    :question_id,
    :redcap_response_value,
    :numeric_value,
    :include_popup_information,
    :popup_information,
    :skip_logic_targets,
    :has_skip_logic

  def skip_logic_targets
    if !instance_options[:skip_skip_logic_targets]
      slts = object.skip_logic_targets.ordered
      slts.map do |slt| 
        s = SkipLogicTargetSerializer.new(slt)
        adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
        adapter.as_json
      end
    end
  end

  def has_skip_logic
    object.skip_logic_target_count > 0
  end

end

class QuestionSerializer < ActiveModel::Serializer
  
  attributes :id,
    :question_text,
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
    :current_treatment_option_ids,
    :slider_left_label,
    :slider_right_label,
    :slider_granularity,
    :num_decimals_to_round_to,
    :can_change_response,
    :unit_of_measurement,
    :slider_midpoint_label,
    :post_question_text,
    :side_text,
    :skippable,
    :special_flag,
    :is_exclusive,
    :randomized_response_order,
    :min_number,
    :max_number,
    :min_chars,
    :max_chars,
    :question_responses,
    :grid_questions,
    :units_array,
    :remote_data_target,
    :remote_data_target_type,
    :backend_identifier,
    :question_page_id

  # def skip_logic_targets
  #   if !instance_options[:skip_skip_logic_targets]
  #     slts = object.skip_logic_targets.ordered
  #     slts.map do |slt| 
  #       s = SkipLogicTargetSerializer.new(slt)
  #       adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
  #       adapter.as_json
  #     end
  #   end
  # end

  def question_responses
    qrs = object.question_responses
    qrs.map do |qr| 
      s = QuestionResponseSerializer.new(qr, skip_skip_logic_targets: instance_options[:skip_skip_logic_targets])
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    end
  end

  def grid_questions
    if object.question_response_type == "grid"
      gqs = object.grid_questions
      gqs.map do |gq| 
        s = QuestionSerializer.new(gq, skip_skip_logic_targets: instance_options[:skip_skip_logic_targets])
        adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
        adapter.as_json
      end
    else
      []
    end
  end

  #has_many :question_responses, serializer: QuestionResponseSerializer, skip_skip_logic_targets: instance_options[:skip_skip_logic_targets]
  #has_many :grid_questions, serializer: QuestionSerializer, skip_skip_logic_targets: instance_options[:skip_skip_logic_targets]
  has_many :my_sql_question_params, serializer: MySqlQuestionParamSerializer
    
end

