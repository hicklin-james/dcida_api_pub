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

FactoryGirl.define do
  factory :nav_link do
    link_href "https://www.google.com"
    link_text "Test text"
    
    after(:build) do |nav_link, evaluator|
      if nav_link.decision_aid_id and DecisionAid.exists?(nav_link.decision_aid_id)
        nav_link.initialize_order(DecisionAid.find(nav_link.decision_aid_id).nav_links_count)
      end
    end
  end
end
