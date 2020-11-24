# == Schema Information
#
# Table name: decision_aid_user_responses
#
#  id                    :integer          not null, primary key
#  question_response_id  :integer
#  response_value        :text
#  question_id           :integer          not null
#  decision_aid_user_id  :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  number_response_value :float
#  lookup_table_value    :float
#  option_id             :integer
#  json_response_value   :json
#  selected_unit         :string
#

class RedcapDecisionAidUserResponse < DecisionAidUserResponse

  def get_relevant_value_for_target(question, response_json)
    case question.question_response_type 
    when "text"
      self.response_value
    when "radio", "yes_no"
      if self.question_response_id
        response_json[self.question_response_id.to_s]
      else
        nil
      end
    when "ranking"
      "[TODO RANKING TYPE]"
    when "number", "slider"
      if self.number_response_value
        if question.hidden
          sprintf("%.#{question.num_decimals_to_round_to}f", self.number_response_value.round(question.num_decimals_to_round_to))
        else
          self.number_response_value.round
        end
      end
    when "lookup_table"
      v = self.lookup_table_value.to_f
      if v % 1 == 0
        v.to_i
      else
        v
      end
    when "json"
      if self.json_response_value
        self.json_response_value
      else
        nil
      end
    else
      nil
    end
  end

end
