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

class DecisionAidUserBwQuestionSetResponseSerializer < ActiveModel::Serializer

  attributes :id,
  :bw_question_set_response_id, 
  :best_property_level_id,
  :worst_property_level_id,
  :question_set

end
