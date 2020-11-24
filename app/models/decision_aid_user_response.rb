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

class DecisionAidUserResponse < ApplicationRecord

  # one response per question
  validates :question_response_id, uniqueness: {scope: :decision_aid_user_id, allow_blank: true, if: :question_response_id_changed?}
  validates :question_id, uniqueness: {scope: :decision_aid_user_id, if: :question_id_changed?}
  validates :decision_aid_user_id, presence: true
  validates :number_response_value, numericality: { allow_blank: true }

  belongs_to :question
  belongs_to :question_response, optional: true
  belongs_to :decision_aid_user
  counter_culture :decision_aid_user

  # for current_treatment questions
  belongs_to :option, optional: true

  def number_response_value
    rv = self[:number_response_value]
    if rv and rv == rv.floor
      rv.to_i
    else
      rv
    end
  end

end
