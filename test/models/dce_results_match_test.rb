# == Schema Information
#
# Table name: dce_results_matches
#
#  id                   :integer          not null, primary key
#  decision_aid_id      :integer
#  response_combination :integer          is an Array
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  option_match_hash    :json
#

require 'test_helper'

class DceResultsMatchTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
