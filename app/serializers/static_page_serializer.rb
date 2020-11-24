# == Schema Information
#
# Table name: static_pages
#
#  id                  :integer          not null, primary key
#  page_text           :text
#  page_text_published :text
#  page_title          :text
#  static_page_order   :integer          not null
#  decision_aid_id     :integer
#  page_slug           :text
#  created_by_user_id  :integer
#  updated_by_user_id  :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class StaticPageSerializer < ActiveModel::Serializer
  attributes :id,
    :page_text,
    :page_title,
    :static_page_order,
    :decision_aid_id,
    :page_slug
end
