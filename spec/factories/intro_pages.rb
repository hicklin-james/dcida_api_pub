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

FactoryGirl.define do
  factory :intro_page do
  	description "test"
  end
end
