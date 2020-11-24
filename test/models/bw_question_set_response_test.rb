# == Schema Information
#
# Table name: bw_question_set_responses
#
#  id                 :integer          not null, primary key
#  question_set       :integer
#  property_level_ids :integer          is an Array
#  decision_aid_id    :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  block_number       :integer          default(1), not null
#

require 'test_helper'

class BwQuestionSetResponseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
