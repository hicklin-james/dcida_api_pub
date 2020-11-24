# == Schema Information
#
# Table name: decision_aid_user_dce_question_set_responses
#
#  id                           :integer          not null, primary key
#  dce_question_set_response_id :integer
#  decision_aid_user_id         :integer
#  question_set                 :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  fallback_question_set_id     :integer
#  option_confirmed             :boolean
#

class DecisionAidUserDceQuestionSetResponseSerializer < ActiveModel::Serializer

  attributes :id,
  :dce_question_set_response_id, 
  :decision_aid_user_id,
  :question_set,
  :fallback_question_set_id,
  :option_confirmed

end
