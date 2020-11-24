# == Schema Information
#
# Table name: my_sql_question_params
#
#  id                          :integer          not null, primary key
#  param_source                :integer
#  param_type                  :string
#  value                       :string
#  my_sql_question_param_order :integer
#  question_id                 :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#

class MySqlQuestionParam < ApplicationRecord
  include Shared::Orderable

  enum param_source: { question_response: 0, input: 1}

  acts_as_orderable :my_sql_question_param_order, :order_scope
  attr_writer :update_order_after_destroy

  scope :ordered, ->{ order(my_sql_question_param_order: :asc) }

  def create_input_param(decision_aid_user, response_hash)
    if param_source == "question_response"
      match = /\[question_([0-9]+)( numeric)?\]/.match(self.value)
      if match
        question_id = match[1]
        numeric = match[2]
        #puts response_hash
        r = response_hash[question_id.to_i]
        val = ""
        if r
          case r.question_response_type
          when Question.question_response_types[:text]
            val = r.response_value
          when Question.question_response_types[:radio], Question.question_response_types[:yes_no]
            v = (if numeric then r.numeric_response_value else r.question_response_value end)
            if v % 1 == 0
              val = v.to_i
            else
              val = v
            end
          when Question.question_response_types[:number]
            val = r.number_response_value
          when Question.question_response_types[:lookup_table]
            v = r.lookup_table_value.to_f
            if v % 1 == 0
              val = v.to_i
            else
              val = v
            end
          else
            val = ""
          end
        end
        val.to_s
      end
    else
      self.value.to_s
    end
  end

  private

  def update_order_after_destroy
    true
  end

  def order_scope
    MySqlQuestionParam.where(question_id: question_id).order(my_sql_question_param_order: :asc)
  end
end
