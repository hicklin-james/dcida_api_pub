# == Schema Information
#
# Table name: decision_aid_user_skip_results
#
#  id                      :integer          not null, primary key
#  source_question_page_id :integer          not null
#  decision_aid_user_id    :integer          not null
#  target_type             :integer          not null
#  target_question_page_id :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

require 'rails_helper'

RSpec.describe DecisionAidUserSkipResult, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
