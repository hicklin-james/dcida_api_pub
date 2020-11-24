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

class SummaryPageSerializer < ActiveModel::Serializer
  attributes :id,
    :decision_aid_id,
    :include_admin_summary_email, 
    :is_primary, 
    :summary_email_addresses,
    :backend_identifier,
    :title

  def summary_email_addresses
    if !object.summary_email_addresses
      []
    else
      object.summary_email_addresses
    end
  end

  def title
    if object.backend_identifier then object.backend_identifier else "Summary page #{object.id}" end
  end
end
