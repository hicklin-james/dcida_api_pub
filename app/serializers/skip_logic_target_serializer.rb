# == Schema Information
#
# Table name: skip_logic_targets
#
#  id                      :integer          not null, primary key
#  question_page_id        :integer
#  question_response_id    :integer
#  decision_aid_id         :integer
#  target_entity           :integer
#  skip_question_page_id   :integer
#  skip_page_url           :string
#  skip_logic_target_order :integer          not null
#  created_by_user_id      :integer
#  updated_by_user_id      :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class SkipLogicConditionSerializer < ActiveModel::Serializer
  
  attributes :id,
    :skip_logic_target_id,
    :decision_aid_id,
    :condition_entity,
    :entity_lookup,
    :entity_value_key,
    :value_to_match,
    :logical_operator,
    :skip_logic_condition_order

end

class SkipLogicTargetSerializer < ActiveModel::Serializer
  
  attributes :id,
    :question_page_id,
    :question_response_id,
    :decision_aid_id,
    :target_entity,
    :skip_question_page_id,
    :skip_page_url,
    :skip_logic_target_order,
    :skip_logic_conditions,
    :include_query_params

  def skip_logic_conditions

    slcs = object.skip_logic_conditions.ordered
    slcs.map do |slc| 
      s = SkipLogicConditionSerializer.new(slc)
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    end
  end

end
