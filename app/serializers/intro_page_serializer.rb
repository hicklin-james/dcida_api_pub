# == Schema Information
#
# Table name: intro_pages
#
#  id                    :integer          not null, primary key
#  description           :text
#  description_published :text
#  decision_aid_id       :integer
#  intro_page_order      :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  created_by_user_id    :integer
#  updated_by_user_id    :integer
#

class IntroPageSerializer < ActiveModel::Serializer
  attributes :id,
    :description,
    :decision_aid_id,
    :intro_page_order
end
