# == Schema Information
#
# Table name: dce_question_sets
#
#  id                     :integer          not null, primary key
#  decision_aid_id        :integer
#  question_title         :string
#  dce_question_set_order :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require 'rails_helper'

RSpec.describe DceQuestionSet, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
