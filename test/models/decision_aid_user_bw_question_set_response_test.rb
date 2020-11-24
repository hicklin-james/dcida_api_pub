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

require 'test_helper'

class DecisionAidUserBwQuestionSetResponseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
