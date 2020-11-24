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

require 'test_helper'

class DecisionAidUserDceQuestionSetResponseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
