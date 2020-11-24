# == Schema Information
#
# Table name: nav_links
#
#  id                 :integer          not null, primary key
#  link_href          :string
#  link_text          :string
#  link_location      :integer
#  nav_link_order     :integer          not null
#  decision_aid_id    :integer
#  created_by_user_id :integer
#  updated_by_user_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class NavLinkSerializer < ActiveModel::Serializer
  attributes :id,
    :link_href,
    :link_text,
    :link_location,
    :nav_link_order,
    :decision_aid_id
end
