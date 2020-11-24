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

class DecisionAidUserDceQuestionSetResponse < ApplicationRecord

  validates_presence_of :dce_question_set_response_id, :decision_aid_user_id, :question_set
  belongs_to :dce_question_set_response, optional: true
  belongs_to :decision_aid_user
  counter_culture :decision_aid_user

  default_scope { order(question_set: :asc) }

end
