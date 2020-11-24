# == Schema Information
#
# Table name: skip_logic_conditions
#
#  id                         :integer          not null, primary key
#  skip_logic_target_id       :integer
#  decision_aid_id            :integer
#  condition_entity           :integer
#  entity_lookup              :string
#  entity_value_key           :string
#  value_to_match             :string
#  logical_operator           :integer
#  skip_logic_condition_order :integer          not null
#  created_by_user_id         :integer
#  updated_by_user_id         :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

class SkipLogicCondition < ApplicationRecord
  include Shared::UserStamps
  include Shared::CrossCloneable

  belongs_to :skip_logic_target, inverse_of: :skip_logic_conditions
  belongs_to :decision_aid

  validates :decision_aid_id, :skip_logic_target, :condition_entity, :skip_logic_condition_order, presence: true

  enum condition_entity: {always: 1, dce_question_set_response: 2, question_response: 3}

  scope :ordered, ->{ order(skip_logic_condition_order: :asc) }

  enum logical_operator: {logical_and: 1, logical_or: 2}

  def evaluate_condition(dau)
    case self.condition_entity
      when "always"
        return true
      when "dce_question_set_response"
        lookup_keys = ["A", "B", "C", "D", "E", "F", "G"]
        rvs = DecisionAidUserDceQuestionSetResponse
              .where(question_set: self.entity_lookup.to_i, decision_aid_user_id: dau.id)
              .joins("LEFT OUTER JOIN dce_question_set_responses as dqsr ON 
                  CASE WHEN decision_aid_user_dce_question_set_responses.dce_question_set_response_id = -1 THEN
                    dqsr.is_opt_out = true
                  ELSE
                    decision_aid_user_dce_question_set_responses.dce_question_set_response_id = dqsr.id
                  END"
              )
              .select("dqsr.response_value")
        if rvs.length > 0
          v = rvs.first.response_value
          return v == value_to_match.to_i
        end
      when "question_response"
        daurs = DecisionAidUserResponse
                .where(question_id: self.entity_lookup.to_i, decision_aid_user_id: dau.id)
                .joins("LEFT OUTER JOIN questions q ON decision_aid_user_responses.question_id = q.id")
                .select("q.question_response_type AS question_response_type, question_response_id, response_value, number_response_value, lookup_table_value, option_id, json_response_value")
                
        if daurs.length > 0
          v = daurs.first
          case Question.question_response_types.invert[v.question_response_type]
            when "radio", "yes_no"
              return v.question_response_id == self.value_to_match.to_i
            else
              puts "RESPONSE TYPE NOT SUPPORTED FOR SKIP LOGIC"
          end
        end
    end

    return false
  end

end
