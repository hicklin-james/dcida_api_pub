# == Schema Information
#
# Table name: summary_pages
#
#  id                          :integer          not null, primary key
#  decision_aid_id             :integer          not null
#  summary_panels_count        :integer          default(0), not null
#  include_admin_summary_email :boolean          default(FALSE)
#  is_primary                  :boolean          default(FALSE)
#  summary_email_addresses     :string           is an Array
#  created_by_user_id          :integer
#  updated_by_user_id          :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  backend_identifier          :string
#

class SummaryPage < ApplicationRecord
  include Shared::UserStamps
  include Shared::CrossCloneable

  belongs_to :decision_aid

  validates :decision_aid_id, presence: true

  has_many :summary_panels, dependent: :destroy
  has_many :decision_aid_user_summary_pages

  counter_culture :decision_aid

  default_scope { order(created_at: :asc) }
end
