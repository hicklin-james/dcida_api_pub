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

class DceResultsMatch < ApplicationRecord
  include Shared::CrossCloneable

  validates :decision_aid_id, :response_combination, :option_match_hash, presence: true
  validates :response_combination, uniqueness: {scope: :decision_aid_id,
    message: "should be unique to the csv file. Check your question_set response combinations and try again." }
  belongs_to :decision_aid

end
