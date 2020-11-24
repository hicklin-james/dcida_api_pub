# == Schema Information
#
# Table name: decision_aid_user_summary_pages
#
#  id                             :integer          not null, primary key
#  decision_aid_user_id           :integer
#  summary_page_id                :integer
#  summary_page_file_file_name    :string
#  summary_page_file_content_type :string
#  summary_page_file_file_size    :integer
#  summary_page_file_updated_at   :datetime
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#

require 'rails_helper'

RSpec.describe DecisionAidUserSummaryPage, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
