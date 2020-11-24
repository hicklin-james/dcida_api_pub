# == Schema Information
#
# Table name: question_pages
#
#  id                      :integer          not null, primary key
#  section                 :integer
#  question_page_order     :integer          not null
#  decision_aid_id         :integer          not null
#  created_by_user_id      :integer
#  updated_by_user_id      :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  skip_logic_target_count :integer          default(0), not null
#

require 'rails_helper'

RSpec.describe QuestionPage, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
