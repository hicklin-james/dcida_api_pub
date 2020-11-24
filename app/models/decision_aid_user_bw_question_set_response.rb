# == Schema Information
#
# Table name: decision_aid_user_bw_question_set_responses
#
#  id                          :integer          not null, primary key
#  bw_question_set_response_id :integer
#  decision_aid_user_id        :integer
#  question_set                :integer
#  best_property_level_id      :integer
#  worst_property_level_id     :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#

class DecisionAidUserBwQuestionSetResponse < ApplicationRecord

  validates :best_property_level_id, :worst_property_level_id, :question_set, :decision_aid_user_id, :bw_question_set_response_id, presence: true
  validates :question_set, uniqueness: {scope: :decision_aid_user_id}

  counter_culture :decision_aid_user
  belongs_to :decision_aid_user
  belongs_to :bw_question_set_response, optional: true
  
  belongs_to :best_property_level, class_name: "PropertyLevel"
  belongs_to :worst_property_level, class_name: "PropertyLevel"
end
