# == Schema Information
#
# Table name: dce_question_set_responses
#
#  id                  :integer          not null, primary key
#  question_set        :integer
#  response_value      :integer
#  property_level_hash :json
#  decision_aid_id     :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  block_number        :integer          default(1), not null
#  is_opt_out          :boolean          default(FALSE)
#  dce_question_set_id :integer
#

require 'test_helper'

class DceQuestionSetResponseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
