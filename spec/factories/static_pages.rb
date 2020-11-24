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

FactoryGirl.define do
  factory :static_page do
    page_text "Page text"
    page_title "Page title"
    page_slug "page_slug"

    after(:build) do |static_page, evaluator|
      if static_page.decision_aid_id and DecisionAid.exists?(static_page.decision_aid_id)
        static_page.initialize_order(DecisionAid.find(static_page.decision_aid_id).static_pages_count)
      end
    end
  end
end
